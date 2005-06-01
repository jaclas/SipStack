{
  (c) 2004 Directorate of New Technologies, Royal National Institute for Deaf people (RNID)

  The RNID licence covers this unit. Read the licence at:
      http://www.ictrnid.org.uk/docs/gw/rnid_license.txt

  This unit contains code written by:
    * Frank Shearar
}
unit IdSipTransport;

interface

uses
  Classes, Contnrs, IdBaseThread, IdException, IdInterfacedObject,
  IdNotification, IdSipLocator, IdSipMessage, IdSipServerNotifier,
  IdSipTcpClient, IdSipTcpServer, IdSipTlsServer, IdSipUdpServer,
  IdSocketHandle, IdSSLOpenSSL, IdTCPConnection, IdTimerQueue, SyncObjs,
  SysUtils;

type
  TIdSipTransport = class;
  TIdSipTransportClass = class of TIdSipTransport;

  // I provide a protocol for objects that want tolisten for incoming messages.
  IIdSipTransportListener = interface
    ['{D3F0A0D5-A4E9-42BD-B337-D5B3C652F340}']
    procedure OnException(E: Exception;
                          const Reason: String);
    procedure OnReceiveRequest(Request: TIdSipRequest;
                               Receiver: TIdSipTransport);
    procedure OnReceiveResponse(Response: TIdSipResponse;
                                Receiver: TIdSipTransport);
    procedure OnRejectedMessage(const Msg: String;
                                const Reason: String);
  end;

  // I listen for when messages are sent, rather than received. You could use
  // me as a logger/debugging tool, for instance.
  IIdSipTransportSendingListener = interface
    ['{2E451F5D-5053-4A2C-BE5F-BB68E5CB3A6D}']
    procedure OnSendRequest(Request: TIdSipRequest;
                            Sender: TIdSipTransport);
    procedure OnSendResponse(Response: TIdSipResponse;
                             Sender: TIdSipTransport);
  end;

  // I provide functionality common to all transports.
  // Instances of my subclasses may bind to a single IP/port. (Of course,
  // UDP/localhost/5060 != TCP/localhost/5060.). I receive messages from
  // the network through means defined in my subclasses, process them
  // in various ways, and present them to my listeners. Together, all the
  // instances of my subclasses form the Transport layer of the SIP stack.
  TIdSipTransport = class(TIdInterfacedObject,
                          IIdSipMessageListener)
  private
    fHostName:                 String;
    fTimeout:                  Cardinal;
    fTimer:                    TIdTimerQueue;
    fUseRport:                 Boolean;
    TransportListeners:        TIdNotificationList;
    TransportSendingListeners: TIdNotificationList;

    procedure RewriteOwnVia(Msg: TIdSipMessage);
  protected
    procedure ChangeBinding(const Address: String; Port: Cardinal); virtual; abstract;
    procedure DestroyServer; virtual;
    function  GetAddress: String; virtual; abstract;
    function  GetBindings: TIdSocketHandles; virtual; abstract;
    function  GetPort: Cardinal; virtual; abstract;
    procedure InstantiateServer; virtual;
    procedure NotifyTransportListeners(Request: TIdSipRequest); overload;
    procedure NotifyTransportListeners(Response: TIdSipResponse); overload;
    procedure NotifyTransportListenersOfException(E: Exception;
                                                  const Reason: String);
    procedure NotifyTransportListenersOfRejectedMessage(const Msg: String;
                                                        const Reason: String);
    procedure NotifyTransportSendingListeners(Request: TIdSipRequest); overload;
    procedure NotifyTransportSendingListeners(Response: TIdSipResponse); overload;
    procedure OnException(E: Exception;
                          const Reason: String);
    procedure OnMalformedMessage(const Msg: String;
                                 const Reason: String);
    procedure OnReceiveRequest(Request: TIdSipRequest;
                               ReceivedFrom: TIdSipConnectionBindings); virtual;
    procedure OnReceiveResponse(Response: TIdSipResponse;
                                ReceivedFrom: TIdSipConnectionBindings);
    procedure ReturnBadRequest(Request: TIdSipRequest;
                               Target: TIdSipConnectionBindings);
    procedure SendRequest(R: TIdSipRequest;
                          Dest: TIdSipLocation); virtual;
    procedure SendResponse(R: TIdSipResponse;
                           Dest: TIdSipLocation); virtual;
    function  SentByIsRecognised(Via: TIdSipViaHeader): Boolean; virtual;
    procedure SetAddress(const Value: String); virtual;
    procedure SetPort(Value: Cardinal);
    procedure SetTimeout(Value: Cardinal); virtual;
    procedure SetTimer(Value: TIdTimerQueue); virtual;

    property Bindings: TIdSocketHandles read GetBindings;
  public
    class function  DefaultPort: Cardinal; virtual;
    class function  GetTransportType: String; virtual; abstract;
    class function  IsSecure: Boolean; virtual;
    class function  SrvPrefix: String; virtual;
    class function  SrvQuery(const Domain: String): String;
    class function  UriScheme: String;

    constructor Create; virtual;
    destructor  Destroy; override;

    procedure AddTransportListener(const Listener: IIdSipTransportListener);
    procedure AddTransportSendingListener(const Listener: IIdSipTransportSendingListener);
    function  DefaultTimeout: Cardinal; virtual;
    function  IsNull: Boolean; virtual;
    function  IsReliable: Boolean; virtual;
    procedure RemoveTransportListener(const Listener: IIdSipTransportListener);
    procedure RemoveTransportSendingListener(const Listener: IIdSipTransportSendingListener);
    procedure Send(Msg: TIdSipMessage;
                   Dest: TIdSipLocation);
    procedure Start; virtual;
    procedure Stop; virtual;

    property Address:  String        read GetAddress write SetAddress;
    property HostName: String        read fHostName write fHostName;
    property Port:     Cardinal      read GetPort write SetPort;
    property Timeout:  Cardinal      read fTimeout write SetTimeout;
    property Timer:    TIdTimerQueue read fTimer write SetTimer;
    property UseRport: Boolean       read fUseRport write fUseRport;
  end;

  // I supply methods for objects to find out what transports the stack knows
  // about, and information about those transports.
  TIdSipTransportRegistry = class(TObject)
  private
    class function TransportAt(Index: Integer): TIdSipTransportClass;
    class function TransportRegistry: TStrings;
  public
    class function  DefaultPortFor(const Transport: String): Cardinal;
    class procedure InsecureTransports(Result: TStrings);
    class function  IsSecure(const Transport: String): Boolean;
    class procedure RegisterTransport(const Name: String;
                                      const TransportType: TIdSipTransportClass);
    class procedure SecureTransports(Result: TStrings);
    class function  TransportFor(const Transport: String): TIdSipTransportClass;
    class procedure UnregisterTransport(const Name: String);
    class function  UriSchemeFor(const Transport: String): String;
  end;

  TIdSipConnectionTableLock = class;

  // I implement the Transmission Control Protocol (RFC 793) connections for the
  // SIP stack.
  TIdSipTCPTransport = class(TIdSipTransport)
  private
    RunningClients: TThreadList;

    procedure SendMessageTo(Msg: TIdSipMessage;
                            Dest: TIdSipLocation);
    procedure SendMessage(Msg: TIdSipMessage;
                          Dest: TIdSipLocation);
    procedure StopAllClientConnections;
  protected
    ConnectionMap: TIdSipConnectionTableLock;
    Transport:     TIdSipTcpServer;

    procedure ChangeBinding(const Address: String; Port: Cardinal); override;
    procedure DestroyServer; override;
    procedure DoOnAddConnection(Connection: TIdTCPConnection;
                                Request: TIdSipRequest);
    function  GetAddress: String; override;
    function  GetBindings: TIdSocketHandles; override;
    function  GetPort: Cardinal; override;
    procedure InstantiateServer; override;
    procedure SendRequest(R: TIdSipRequest;
                          Dest: TIdSipLocation); override;
    procedure SendResponse(R: TIdSipResponse;
                           Dest: TIdSipLocation); override;
    function  ServerType: TIdSipTcpServerClass; virtual;
    procedure SetTimeout(Value: Cardinal); override;
    procedure SetTimer(Value: TIdTimerQueue); override;
  public
    class function GetTransportType: String; override;
    class function SrvPrefix: String; override;

    constructor Create; override;
    destructor  Destroy; override;

    procedure RemoveClient(ClientThread: TObject);
    procedure Start; override;
    procedure Stop; override;
  end;

  // I allow the sending of TCP requests to happen asynchronously: in my
  // context, I instantiate a TCP client, send a request, and receive
  // messages, usually responses. I schedule Waits for each of these messages so
  // that my Transport handles the response in the context of its Timer.
  TIdSipTcpClientThread = class(TIdBaseThread)
  private
    Client:    TIdSipTcpClient;
    FirstMsg:  TIdSipMessage;
    Transport: TIdSipTCPTransport;

    procedure NotifyOfException(E: Exception);
    procedure ReceiveRequestInTimerContext(Sender: TObject;
                                           R: TIdSipRequest;
                                           ReceivedFrom: TIdSipConnectionBindings); overload;
    procedure ReceiveResponseInTimerContext(Sender: TObject;
                                            R: TIdSipResponse;
                                            ReceivedFrom: TIdSipConnectionBindings); overload;
  protected
    function  ClientType: TIdSipTcpClientClass; virtual;
    procedure Run; override;
  public
    constructor Create(const Host: String;
                       Port: Cardinal;
                       Msg: TIdSipMessage;
                       Transport: TIdSipTCPTransport); reintroduce;
    destructor Destroy; override;

    procedure Terminate; override;
  end;

  TIdSipTlsClientThread = class(TIdSipTcpClientThread)
  protected
    function ClientType: TIdSipTcpClientClass; override;
  end;

  // I represent the (possibly) deferred handling of an exception raised in the
  // process of sending or receiving a message.
  TIdSipMessageExceptionWait = class(TIdWait)
  private
    fExceptionMessage: String;
    fExceptionType:    ExceptClass;
    fReason:           String;
    fTransport:        TIdSipTransport;
  public
    procedure Trigger; override;

    property ExceptionType:    ExceptClass     read fExceptionType write fExceptionType;
    property ExceptionMessage: String          read fExceptionMessage write fExceptionMessage;
    property Reason:           String          read fReason write fReason;
    property Transport:        TIdSipTransport read fTransport write fTransport;
  end;

  // I represent the (possibly) deferred handling of an inbound message.
  TIdSipReceiveMessageWait = class(TIdSipMessageWait)
  private
    fReceivedFrom: TIdSipConnectionBindings;
    fTransport:    TIdSipTransport;
  public
    procedure Trigger; override;

    property ReceivedFrom: TIdSipConnectionBindings read fReceivedFrom write fReceivedFrom;
    property Transport:    TIdSipTransport          read fTransport write fTransport;
  end;

  // I represent a (possibly) deferred receipt of a message.
  TIdSipReceiveTCPMessageWait = class(TIdSipReceiveMessageWait)
  private
    fReceivedFrom: TIdSipConnectionBindings;
    fListeners:    TIdSipServerNotifier;
  public
    procedure Trigger; override;

    property ReceivedFrom: TIdSipConnectionBindings read fReceivedFrom write fReceivedFrom;
    property Listeners:    TIdSipServerNotifier     read fListeners write fListeners;
  end;

  // I implement the Transport Layer Security (RFC 2249) connections for the SIP
  // stack.
  TIdSipTLSTransport = class(TIdSipTCPTransport)
  private
    function  GetOnGetPassword: TPasswordEvent;
    function  GetRootCertificate: TFileName;
    function  GetServerCertificate: TFileName;
    function  GetServerKey: TFileName;
    function  TLS: TIdSipTlsServer;
    procedure SetOnGetPassword(Value: TPasswordEvent);
    procedure SetRootCertificate(Value: TFileName);
    procedure SetServerCertificate(Value: TFileName);
    procedure SetServerKey(Value: TFileName);
  protected
    function  ServerType: TIdSipTcpServerClass; override;
  public
    class function DefaultPort: Cardinal; override;
    class function GetTransportType: String; override;
    class function IsSecure: Boolean; override;
    class function SrvPrefix: String; override;

    property OnGetPassword:     TPasswordEvent read GetOnGetPassword write SetOnGetPassword;
    property RootCertificate:   TFileName      read GetRootCertificate write SetRootCertificate;
    property ServerCertificate: TFileName      read GetServerCertificate write SetServerCertificate;
    property ServerKey:         TFileName      read GetServerKey write SetServerKey;
  end;

  // I implement the Stream Control Transmission Protocol (RFC 3286) connections
  // for the SIP stack.
  TIdSipSCTPTransport = class(TIdSipTransport)
  public
    class function GetTransportType: String; override;
    class function SrvPrefix: String; override;
  end;

  // I implement the User Datagram Protocol (RFC 768) connections for the SIP
  // stack.
  TIdSipUDPTransport = class(TIdSipTransport)
  private
    Transport: TIdSipUdpServer;

  protected
    procedure ChangeBinding(const Address: String; Port: Cardinal); override;
    procedure DestroyServer; override;
    function  GetAddress: String; override;
    function  GetBindings: TIdSocketHandles; override;
    function  GetPort: Cardinal; override;
    procedure InstantiateServer; override;
    procedure OnReceiveRequest(Request: TIdSipRequest;
                               ReceivedFrom: TIdSipConnectionBindings); override;
    procedure SendRequest(R: TIdSipRequest;
                          Dest: TIdSipLocation); override;
    procedure SendResponse(R: TIdSipResponse;
                           Dest: TIdSipLocation); override;
    procedure SetTimer(Value: TIdTimerQueue); override;
  public
    class function GetTransportType: String; override;
    class function SrvPrefix: String; override;

    constructor Create; override;

    function  IsReliable: Boolean; override;
    procedure Start; override;
    procedure Stop; override;
  end;

  // I represent a collection of Transports. I own, and hence manage the
  // lifetimes of, all transports given to me via Add.
  TIdSipTransports = class(TObject)
  private
    List: TObjectList;

    function GetTransports(Index: Integer): TIdSipTransport;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Add(T: TIdSipTransport);
    procedure Clear;
    function  Count: Integer;

    property Transports[Index: Integer]: TIdSipTransport read GetTransports; default;
  end;

  // I relate a request with a TCP connection. I store a COPY of a request
  // while storing a REFERENCE to a connection. Transports construct requests
  // and so bear responsibility for destroying them, and I need to remember
  // these requests.
  TIdSipConnectionTableEntry = class(TObject)
  private
    fConnection: TIdTCPConnection;
    fRequest:    TIdSipRequest;
  public
    constructor Create(Connection:    TIdTCPConnection;
                       CopyOfRequest: TIdSipRequest);
    destructor  Destroy; override;

    property Connection: TIdTCPConnection read fConnection;
    property Request:    TIdSipRequest    read fRequest;
  end;

  // I represent a table containing ordered pairs of (TCP connection, Request).
  // If a transport wishes to send a request or response I match the outbound
  // message against my table of tuples, and return the appropriate TCP
  // connection. My users bear responsibility for informing me when TCP
  // connections appear and disappear.
  TIdSipConnectionTable = class(TObject)
  private
    List: TObjectList;

    procedure ConnectionDisconnected(Sender: TObject);
    function  EntryAt(Index: Integer): TIdSipConnectionTableEntry;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Add(Connection: TIdTCPConnection;
                  Request:    TIdSipRequest);
    function  ConnectionFor(Msg: TIdSipMessage): TIdTCPConnection; overload;
    function  ConnectionFor(Destination: TIdSipLocation): TIdTCPConnection; overload;
    function  Count: Integer;
    procedure Remove(Connection: TIdTCPConnection);
  end;

  TIdSipConnectionTableLock = class(TObject)
  private
    Table: TIdSipConnectionTable;
    Lock:  TCriticalSection;
  public
    constructor Create;
    destructor  Destroy; override;

    function  LockList: TIdSipConnectionTable;
    procedure UnlockList;
  end;

  // I represent a (possibly) deferred handling of an exception by using a
  // TNotifyEvent.
  TIdSipExceptionWait = class(TIdNotifyEventWait)
  private
    fExceptionMsg:  String;
    fExceptionType: ExceptClass;
    fReason:        String;
  public
    property ExceptionMsg:  String      read fExceptionMsg write fExceptionMsg;
    property ExceptionType: ExceptClass read fExceptionType write fExceptionType;
    property Reason:        String      read fReason write fReason;
  end;

  // Look at IIdSipTransportListener's declaration.
  TIdSipTransportExceptionMethod = class(TIdNotification)
  private
    fException: Exception;
    fReason:    String;
  public
    procedure Run(const Subject: IInterface); override;

    property Exception: Exception read fException write fException;
    property Reason:    String    read fReason write fReason;
  end;

  // Look at IIdSipTransportListener's declaration.
  TIdSipTransportReceiveRequestMethod = class(TIdNotification)
  private
    fReceiver: TIdSipTransport;
    fRequest:  TIdSipRequest;
  public
    procedure Run(const Subject: IInterface); override;

    property Receiver: TIdSipTransport read fReceiver write fReceiver;
    property Request:  TIdSipRequest   read fRequest write fRequest;
  end;

  // Look at IIdSipTransportListener's declaration.
  TIdSipTransportReceiveResponseMethod = class(TIdNotification)
  private
    fReceiver: TIdSipTransport;
    fResponse: TIdSipResponse;
  public
    procedure Run(const Subject: IInterface); override;

    property Receiver: TIdSipTransport read fReceiver write fReceiver;
    property Response: TIdSipResponse  read fResponse write fResponse;
  end;

  // Look at IIdSipTransportListener's declaration.
  TIdSipTransportRejectedMessageMethod = class(TIdNotification)
  private
    fMsg:    String;
    fReason: String;
  public
    procedure Run(const Subject: IInterface); override;

    property Msg:    String read fMsg write fMsg;
    property Reason: String read fReason write fReason;
  end;

  // Look at IIdSipTransportSendingListener's declaration.
  TIdSipTransportSendingRequestMethod = class(TIdNotification)
  private
    fSender:  TIdSipTransport;
    fRequest: TIdSipRequest;
  public
    procedure Run(const Subject: IInterface); override;

    property Sender:  TIdSipTransport read fSender write fSender;
    property Request: TIdSipRequest   read fRequest write fRequest;
  end;

  // Look at IIdSipTransportSendingListener's declaration.
  TIdSipTransportSendingResponseMethod = class(TIdNotification)
  private
    fSender: TIdSipTransport;
    fResponse: TIdSipResponse;
  public
    procedure Run(const Subject: IInterface); override;

    property Sender:   TIdSipTransport read fSender write fSender;
    property Response: TIdSipResponse  read fResponse write fResponse;
  end;

  EIdSipTransport = class(Exception)
  private
    fSipMessage: TIdSipMessage;
    fTransport:  TIdSipTransport;
  public
    constructor Create(Transport: TIdSipTransport;
                       SipMessage: TIdSipMessage;
                       const Msg: String);

    property SipMessage: TIdSipMessage   read fSipMessage;
    property Transport:  TIdSipTransport read fTransport;
  end;

  EUnknownTransport = class(EIdException);

const
  ExceptionDuringTcpClientRequestSend = 'Something went wrong sending a TCP '
                                      + 'request or receiving a response to one.';
  MustHaveAtLeastOneVia   = 'An outbound message must always have at least one '
                          + 'Via, namely, this stack.';
  RequestNotSentFromHere  = 'The request to which this response replies could '
                          + 'not have been sent from here.';
  WrongTransport          = 'This transport only supports %s  messages but '
                          + 'received a %s message.';

const
  ItemNotFoundIndex = -1;                          

implementation

uses
  IdSipConsts, IdSipDns, IdTCPServer;

var
  GTransportTypes: TStrings;

//******************************************************************************
//* TIdSipTransport                                                            *
//******************************************************************************
//* TIdSipTransport Public methods *********************************************

class function TIdSipTransport.DefaultPort: Cardinal;
begin
  Result := IdPORT_SIP;
end;

class function TIdSipTransport.IsSecure: Boolean;
begin
  Result := false;
end;

class function TIdSipTransport.SrvPrefix: String;
begin
  Result := Self.ClassName + ' hasn''t overridden SrvPrefix';
end;

class function TIdSipTransport.SrvQuery(const Domain: String): String;
begin
  Result := Self.SrvPrefix + '.' + Domain;
end;

class function TIdSipTransport.UriScheme: String;
begin
  if Self.IsSecure then
    Result := SipsScheme
  else
    Result := SipScheme;
end;

constructor TIdSipTransport.Create;
begin
  inherited Create;

  Self.TransportListeners        := TIdNotificationList.Create;
  Self.TransportSendingListeners := TIdNotificationList.Create;

  Self.InstantiateServer;

  Self.Timeout  := Self.DefaultTimeout;
  Self.UseRport := false;
end;

destructor TIdSipTransport.Destroy;
begin
  Self.TransportSendingListeners.Free;
  Self.TransportListeners.Free;

  Self.DestroyServer;

  inherited Destroy;
end;

procedure TIdSipTransport.AddTransportListener(const Listener: IIdSipTransportListener);
begin
  Self.TransportListeners.AddListener(Listener);
end;

procedure TIdSipTransport.AddTransportSendingListener(const Listener: IIdSipTransportSendingListener);
begin
  Self.TransportSendingListeners.AddListener(Listener);
end;

function TIdSipTransport.DefaultTimeout: Cardinal;
begin
  Result := 5000;
end;

function TIdSipTransport.IsNull: Boolean;
begin
  Result := false;
end;

function TIdSipTransport.IsReliable: Boolean;
begin
  Result := true;
end;

procedure TIdSipTransport.RemoveTransportListener(const Listener: IIdSipTransportListener);
begin
  Self.TransportListeners.RemoveListener(Listener);
end;

procedure TIdSipTransport.RemoveTransportSendingListener(const Listener: IIdSipTransportSendingListener);
begin
  Self.TransportSendingListeners.RemoveListener(Listener);
end;

procedure TIdSipTransport.Send(Msg: TIdSipMessage;
                               Dest: TIdSipLocation);
begin
  try
    Assert(not Msg.IsMalformed,
           'A Transport must NEVER send invalid messages onto the network ('
         + Msg.ParseFailReason + ')');
    if Msg.IsRequest then
      Self.SendRequest(Msg as TIdSipRequest, Dest)
    else
      Self.SendResponse(Msg as TIdSipResponse, Dest);
  except
    on E: EIdException do
      raise EIdSipTransport.Create(Self, Msg, E.Message);
  end;
end;

procedure TIdSipTransport.Start;
begin
end;

procedure TIdSipTransport.Stop;
begin
end;

//* TIdSipTransport Protected methods ******************************************

procedure TIdSipTransport.DestroyServer;
begin
end;

procedure TIdSipTransport.InstantiateServer;
begin
end;

procedure TIdSipTransport.NotifyTransportListeners(Request: TIdSipRequest);
var
  Notification: TIdSipTransportReceiveRequestMethod;
begin
  Assert(not Request.IsMalformed,
         'A Transport must NEVER send invalid requests up the stack ('
       + Request.ParseFailReason + ')');

  Notification := TIdSipTransportReceiveRequestMethod.Create;
  try
    Notification.Receiver := Self;
    Notification.Request  := Request;

    Self.TransportListeners.Notify(Notification);
  finally
    Notification.Free;
  end;
end;

procedure TIdSipTransport.NotifyTransportListeners(Response: TIdSipResponse);
var
  Notification: TIdSipTransportReceiveResponseMethod;
begin
  Assert(not Response.IsMalformed,
         'A Transport must NEVER send invalid responses up the stack ('
       + Response.ParseFailReason + ')');

  Notification := TIdSipTransportReceiveResponseMethod.Create;
  try
    Notification.Receiver := Self;
    Notification.Response := Response;

    Self.TransportListeners.Notify(Notification);
  finally
    Notification.Free;
  end;
end;

procedure TIdSipTransport.NotifyTransportListenersOfException(E: Exception;
                                                              const Reason: String);
var
  Notification: TIdSipTransportExceptionMethod;
begin
  Notification := TIdSipTransportExceptionMethod.Create;
  try
    Notification.Exception := E;
    Notification.Reason    := Reason;

    Self.TransportListeners.Notify(Notification);
  finally
    Notification.Free;
  end;
end;

procedure TIdSipTransport.NotifyTransportListenersOfRejectedMessage(const Msg: String;
                                                                    const Reason: String);
var
  Notification: TIdSipTransportRejectedMessageMethod;
begin
  Notification := TIdSipTransportRejectedMessageMethod.Create;
  try
    Notification.Msg    := Msg;
    Notification.Reason := Reason;

    Self.TransportListeners.Notify(Notification);
  finally
    Notification.Free;
  end;
end;

procedure TIdSipTransport.NotifyTransportSendingListeners(Request: TIdSipRequest);
var
  Notification: TIdSipTransportSendingRequestMethod;
begin
  Notification := TIdSipTransportSendingRequestMethod.Create;
  try
    Notification.Sender  := Self;
    Notification.Request := Request;

    Self.TransportSendingListeners.Notify(Notification);
  finally
    Notification.Free;
  end;
end;

procedure TIdSipTransport.NotifyTransportSendingListeners(Response: TIdSipResponse);
var
  Notification: TIdSipTransportSendingResponseMethod;
begin
  Notification := TIdSipTransportSendingResponseMethod.Create;
  try
    Notification.Sender   := Self;
    Notification.Response := Response;

    Self.TransportSendingListeners.Notify(Notification);
  finally
    Notification.Free;
  end;
end;

procedure TIdSipTransport.OnException(E: Exception;
                                      const Reason: String);
begin
  Self.NotifyTransportListenersOfException(E, Reason);
end;

procedure TIdSipTransport.OnMalformedMessage(const Msg: String;
                                             const Reason: String);
begin
  Self.NotifyTransportListenersOfRejectedMessage(Msg, Reason);
end;

procedure TIdSipTransport.OnReceiveRequest(Request: TIdSipRequest;
                                           ReceivedFrom: TIdSipConnectionBindings);
begin
  if Request.IsMalformed then begin
    Self.NotifyTransportListenersOfRejectedMessage(Request.AsString,
                                                   Request.ParseFailReason);
    Self.ReturnBadRequest(Request, ReceivedFrom);
    Exit;
  end;

  // cf. RFC 3261 section 18.2.1
  if TIdSipParser.IsFQDN(Request.LastHop.SentBy)
    or (Request.LastHop.SentBy <> ReceivedFrom.PeerIP) then
    Request.LastHop.Received := ReceivedFrom.PeerIP;

  // We let the UA handle rejecting messages because of things like the UA
  // not supporting the SIP version or whatnot. This allows us to centralise
  // response generation.
  Self.NotifyTransportListeners(Request);
end;

procedure TIdSipTransport.OnReceiveResponse(Response: TIdSipResponse;
                                            ReceivedFrom: TIdSipConnectionBindings);
begin
  if Response.IsMalformed then begin
    Self.NotifyTransportListenersOfRejectedMessage(Response.AsString,
                                                   Response.ParseFailReason);
    // Drop the malformed response.
    Exit;
  end;

  // cf. RFC 3261 section 18.1.2

  if Self.SentByIsRecognised(Response.LastHop) then begin
    Self.NotifyTransportListeners(Response);
  end
  else
    Self.NotifyTransportListenersOfRejectedMessage(Response.AsString,
                                                   RequestNotSentFromHere);
end;

procedure TIdSipTransport.ReturnBadRequest(Request: TIdSipRequest;
                                           Target: TIdSipConnectionBindings);
var
  Destination: TIdSipLocation;
  Res:         TIdSipResponse;
begin
  Res := TIdSipResponse.InResponseTo(Request, SIPBadRequest);
  try
    Res.StatusText := Request.ParseFailReason;

    Destination := TIdSipLocation.Create(Self.GetTransportType,
                                         Target.PeerIP,
                                         Target.PeerPort);
    try
      Self.SendResponse(Res, Destination);
    finally
      Destination.Free;
    end;
  finally
    Res.Free;
  end;
end;

procedure TIdSipTransport.SendRequest(R: TIdSipRequest;
                                      Dest: TIdSipLocation);
begin
  Self.RewriteOwnVia(R);
  Self.NotifyTransportSendingListeners(R);
end;

procedure TIdSipTransport.SendResponse(R: TIdSipResponse;
                                       Dest: TIdSipLocation);
begin
  Self.NotifyTransportSendingListeners(R);
end;

function TIdSipTransport.SentByIsRecognised(Via: TIdSipViaHeader): Boolean;
var
  I: Integer;
begin
  Result := IsEqual(Via.SentBy, Self.HostName);

  I := 0;

  if not Result then begin
    while (I < Self.Bindings.Count) and not Result do begin
      Result := Result or (Self.Bindings[I].IP = Via.SentBy);

      Inc(I);
    end;
  end;
end;

procedure TIdSipTransport.SetAddress(const Value: String);
begin
  Self.ChangeBinding(Value, Self.Port);
end;

procedure TIdSipTransport.SetPort(Value: Cardinal);
begin
  Self.ChangeBinding(Self.Address, Value);
end;

procedure TIdSipTransport.SetTimeout(Value: Cardinal);
begin
  Self.fTimeout := Value;
end;

procedure TIdSipTransport.SetTimer(Value: TIdTimerQueue);
begin
  Self.fTimer := Value;
end;

//* TIdSipTransport Private methods ********************************************

procedure TIdSipTransport.RewriteOwnVia(Msg: TIdSipMessage);
begin
  Assert(Msg.Path.Length > 0,
         MustHaveAtLeastOneVia);

  Assert(Msg.LastHop.Transport = Self.GetTransportType,
         Format(WrongTransport, [Self.GetTransportType, Msg.LastHop.Transport]));

  Msg.LastHop.SentBy := Self.HostName;
  Msg.LastHop.Port   := Self.Port;

  if Self.UseRport then
    Msg.LastHop.Params[RportParam] := '';
end;

//******************************************************************************
//* TIdSipTransportRegistry                                                    *
//******************************************************************************
//* TIdSipTransportRegistry Public methods *************************************

class function TIdSipTransportRegistry.DefaultPortFor(const Transport: String): Cardinal;
begin
  try
    Result := Self.TransportFor(Transport).DefaultPort;
  except
    on EUnknownTransport do
      Result := TIdSipTransport.DefaultPort;
  end;
end;

class procedure TIdSipTransportRegistry.InsecureTransports(Result: TStrings);
var
  I: Integer;
begin
  for I := 0 to Self.TransportRegistry.Count - 1 do begin
    if not Self.TransportAt(I).IsSecure then
      Result.Add(Self.TransportRegistry[I]);
  end;
end;

class function TIdSipTransportRegistry.IsSecure(const Transport: String): Boolean;
begin
  Result := Self.TransportFor(Transport).IsSecure;
end;

class procedure TIdSipTransportRegistry.RegisterTransport(const Name: String;
                                                          const TransportType: TIdSipTransportClass);
begin
  if (Self.TransportRegistry.IndexOf(Name) = ItemNotFoundIndex) then
    Self.TransportRegistry.AddObject(Name, TObject(TransportType));
end;

class procedure TIdSipTransportRegistry.SecureTransports(Result: TStrings);
var
  I: Integer;
begin
  for I := 0 to Self.TransportRegistry.Count - 1 do begin
    if Self.TransportAt(I).IsSecure then
      Result.Add(Self.TransportRegistry[I]);
  end;
end;

class function TIdSipTransportRegistry.TransportFor(const Transport: String): TIdSipTransportClass;
var
  Index: Integer;
begin
  Index := Self.TransportRegistry.IndexOf(Transport);

  if (Index <> ItemNotFoundIndex) then
    Result := Self.TransportAt(Index)
  else
    raise EUnknownTransport.Create('TIdSipTransport.TransportFor: ' + Transport);
end;

class procedure TIdSipTransportRegistry.UnregisterTransport(const Name: String);
var
  Index: Integer;
begin
  Index := Self.TransportRegistry.IndexOf(Name);
  if (Index <> ItemNotFoundIndex) then
    Self.TransportRegistry.Delete(Index);
end;

class function TIdSipTransportRegistry.UriSchemeFor(const Transport: String): String;
begin
  try
    Result := Self.TransportFor(Transport).UriScheme;
  except
    on EUnknownTransport do
      Result := TIdSipTransport.UriScheme;
  end;
end;

//* TIdSipTransportRegistry Private methods ************************************

class function TIdSipTransportRegistry.TransportAt(Index: Integer): TIdSipTransportClass;
begin
  Result := TIdSipTransportClass(Self.TransportRegistry.Objects[Index]);
end;

class function TIdSipTransportRegistry.TransportRegistry: TStrings;
begin
  Result := GTransportTypes;
end;

//******************************************************************************
//* TIdSipTCPTransport                                                         *
//******************************************************************************
//* TIdSipTCPTransport Public methods ******************************************

class function TIdSipTCPTransport.GetTransportType: String;
begin
  Result := TcpTransport;
end;

class function TIdSipTCPTransport.SrvPrefix: String;
begin
  Result := SrvTcpPrefix;
end;

constructor TIdSipTCPTransport.Create;
begin
  inherited Create;

  Self.ConnectionMap  := TIdSipConnectionTableLock.Create;
  Self.RunningClients := TThreadList.Create;

  Self.Bindings.Add;
end;

destructor TIdSipTCPTransport.Destroy;
begin
  Self.RunningClients.Free;
  Self.ConnectionMap.Free;

  inherited Destroy;
end;

procedure TIdSipTCPTransport.RemoveClient(ClientThread: TObject);
var
  Clients: TList;
begin
  Clients := Self.RunningClients.LockList;
  try
    Clients.Remove(ClientThread);
  finally
    Self.RunningClients.UnlockList;
  end;
end;

procedure TIdSipTCPTransport.Start;
begin
  Self.Transport.Active := true;
end;

procedure TIdSipTCPTransport.Stop;
begin
  Self.Transport.Active := false;

  Self.StopAllClientConnections;
end;

//* TIdSipTCPTransport Protected methods ***************************************

procedure TIdSipTCPTransport.ChangeBinding(const Address: String; Port: Cardinal);
var
  Binding: TIdSocketHandle;
begin
  Self.Stop;

  Self.Transport.Bindings.Clear;
  Self.Bindings.DefaultPort := Port;
  Binding := Self.Bindings.Add;
  Binding.IP   := Address;
  Binding.Port := Port;

  Self.Start;
end;

procedure TIdSipTCPTransport.DestroyServer;
begin
  Self.Transport.Free;
end;

procedure TIdSipTCPTransport.DoOnAddConnection(Connection: TIdTCPConnection;
                                               Request: TIdSipRequest);
var
  Table: TIdSipConnectionTable;
begin
  Table := Self.ConnectionMap.LockList;
  try
    Table.Add(Connection, Request);
  finally
    Self.ConnectionMap.UnlockList;
  end;
end;

function TIdSipTCPTransport.GetAddress: String;
begin
  Result := Self.Transport.Bindings[0].IP;
end;

function TIdSipTCPTransport.GetBindings: TIdSocketHandles;
begin
  Result := Self.Transport.Bindings;
end;

function TIdSipTCPTransport.GetPort: Cardinal;
begin
  Result := Self.Transport.DefaultPort;
end;

procedure TIdSipTCPTransport.InstantiateServer;
begin
  Self.Transport := Self.ServerType.Create(nil);
  Self.Transport.AddMessageListener(Self);

  Self.Transport.OnAddConnection := Self.DoOnAddConnection;
end;

procedure TIdSipTCPTransport.SendRequest(R: TIdSipRequest;
                                         Dest: TIdSipLocation);
begin
  inherited SendRequest(R, Dest);

  Self.SendMessage(R, Dest);
end;

procedure TIdSipTCPTransport.SendResponse(R: TIdSipResponse;
                                          Dest: TIdSipLocation);
begin
  inherited SendResponse(R, Dest);

  Self.SendMessage(R, Dest);
end;

function TIdSipTCPTransport.ServerType: TIdSipTcpServerClass;
begin
  Result := TIdSipTcpServer;
end;

procedure TIdSipTCPTransport.SetTimeout(Value: Cardinal);
begin
  inherited SetTimeout(Value);

  Self.Transport.ReadTimeout       := Value;
  Self.Transport.ConnectionTimeout := Value;
end;

procedure TIdSipTCPTransport.SetTimer(Value: TIdTimerQueue);
begin
  inherited SetTimer(Value);

  Self.Transport.Timer := Value;
end;

//* TIdSipTCPTransport Protected methods ***************************************

procedure TIdSipTCPTransport.SendMessageTo(Msg: TIdSipMessage;
                                           Dest: TIdSipLocation);
begin
  Self.RunningClients.Add(TIdSipTcpClientThread.Create(Dest.IPAddress, Dest.Port, Msg, Self));
end;

procedure TIdSipTCPTransport.SendMessage(Msg: TIdSipMessage;
                                         Dest: TIdSipLocation);
var
  Connection:  TIdTCPConnection;
  Table:       TIdSipConnectionTable;
begin
  Table := Self.ConnectionMap.LockList;
  try
    // Try send the response down the same connection we received the request on.
    Connection := Table.ConnectionFor(Msg);

    if Assigned(Connection) and Connection.Connected then
      Connection.Write(Msg.AsString)
    else begin
      Connection := Table.ConnectionFor(Dest);

      // Otherwise, try find an existing connection to Dest.
      if Assigned(Connection) and Connection.Connected then
        Connection.Write(Msg.AsString)
      else
        // Last resort: make a new connection to Dest.
        Self.SendMessageTo(Msg, Dest);
    end;
  finally
    Self.ConnectionMap.UnlockList;
  end;
end;

procedure TIdSipTCPTransport.StopAllClientConnections;
var
  Clients: TList;
  I:       Integer;
begin
  Clients := Self.RunningClients.LockList;
  try
    for I := 0 to Clients.Count - 1 do
      TIdSipTcpClientThread(Clients[I]).Terminate;
  finally
    Self.RunningClients.UnlockList;
  end;
end;

//******************************************************************************
//* TIdSipTcpClientThread                                                      *
//******************************************************************************
//* TIdSipTcpClientThread Public methods ***************************************

constructor TIdSipTcpClientThread.Create(const Host: String;
                                         Port: Cardinal;
                                         Msg: TIdSipMessage;
                                         Transport: TIdSipTCPTransport);
begin
  Self.FreeOnTerminate := true;

  Self.Client := Self.ClientType.Create(nil);
  Self.Client.Host       := Host;
  Self.Client.OnRequest  := Self.ReceiveRequestInTimerContext;
  Self.Client.OnResponse := Self.ReceiveResponseInTimerContext;
  Self.Client.Port       := Port;

  Self.FirstMsg  := Msg.Copy;
  Self.Transport := Transport;

  inherited Create(false);
end;

destructor TIdSipTcpClientThread.Destroy;
begin
  Self.FirstMsg.Free;
  Self.Client.Free;

  inherited Destroy;
end;

procedure TIdSipTcpClientThread.Terminate;
begin
  Self.Client.Terminated := true;

  inherited Terminate;
end;

//* TIdSipTcpClientThread Protected methods ************************************

function TIdSipTcpClientThread.ClientType: TIdSipTcpClientClass;
begin
  Result := TIdSipTcpClient;
end;

procedure TIdSipTcpClientThread.Run;
begin
  try
    Self.Client.Connect(Self.Transport.Timeout);
    try
      Self.Client.Send(Self.FirstMsg);
      Self.Client.ReceiveMessages;
    finally
      Self.Client.Disconnect;
    end;
  except
    on EIdConnClosedGracefully do;
    on EIdConnectTimeout do;
    on E: Exception do
      Self.NotifyOfException(E);
  end;

  Self.Transport.RemoveClient(Self);
end;

//* TIdSipTcpClientThread Private methods **************************************

procedure TIdSipTcpClientThread.NotifyOfException(E: Exception);
var
  Wait: TIdSipMessageExceptionWait;
begin
  Wait := TIdSipMessageExceptionWait.Create;
  Wait.ExceptionType    := ExceptClass(E.ClassType);
  Wait.ExceptionMessage := E.Message;
  Wait.Reason           := ExceptionDuringTcpClientRequestSend;
  Wait.Transport        := Self.Transport;

  Self.Transport.Timer.AddEvent(TriggerImmediately, Wait);
end;

procedure TIdSipTcpClientThread.ReceiveRequestInTimerContext(Sender: TObject;
                                                             R: TIdSipRequest;
                                                             ReceivedFrom: TIdSipConnectionBindings);
var
  Wait: TIdSipReceiveMessageWait;
begin
  if Self.Terminated then Exit;

  Wait := TIdSipReceiveMessageWait.Create;
  Wait.ReceivedFrom := ReceivedFrom;
  Wait.Message      := R;
  Wait.Transport    := Self.Transport;

  Self.Transport.Timer.AddEvent(TriggerImmediately, Wait);
end;

procedure TIdSipTcpClientThread.ReceiveResponseInTimerContext(Sender: TObject;
                                                              R: TIdSipResponse;
                                                              ReceivedFrom: TIdSipConnectionBindings);
var
  Wait: TIdSipReceiveMessageWait;
begin
  if Self.Terminated then Exit;

  Wait := TIdSipReceiveMessageWait.Create;
  Wait.ReceivedFrom := ReceivedFrom;
  Wait.Message      := R;
  Wait.Transport    := Self.Transport;

  Self.Transport.Timer.AddEvent(TriggerImmediately, Wait);
end;

//******************************************************************************
//* TIdSipTlsClientThread                                                      *
//******************************************************************************
//* TIdSipTlsClientThread Protected methods ************************************

function TIdSipTlsClientThread.ClientType: TIdSipTcpClientClass;
begin
  Result := TIdSipTlsClient;
end;

//******************************************************************************
//* TIdSipMessageExceptionWait                                                 *
//******************************************************************************
//* TIdSipMessageExceptionWait Public methods **********************************

procedure TIdSipMessageExceptionWait.Trigger;
var
  FakeException: Exception;
begin
  FakeException := Self.ExceptionType.Create(Self.ExceptionMessage);
  try
    (Self.Transport as IIdSipMessageListener).OnException(FakeException,
                                                          Self.Reason);
  finally
    FakeException.Free;
  end;
end;

//******************************************************************************
//* TIdSipReceiveMessageWait                                                   *
//******************************************************************************
//* TIdSipReceiveMessageWait Public methods ************************************

procedure TIdSipReceiveMessageWait.Trigger;
begin
  if Self.Message.IsRequest then
    (Self.Transport as IIdSipMessageListener).OnReceiveRequest(Self.Message as TIdSipRequest,
                                                               Self.ReceivedFrom)
  else
    (Self.Transport as IIdSipMessageListener).OnReceiveResponse(Self.Message as TIdSipResponse,
                                                                Self.ReceivedFrom);
end;

//******************************************************************************
//* TIdSipReceiveTCPMessageWait                                                *
//******************************************************************************
//* TIdSipReceiveTCPMessageWait Public methods *********************************

procedure TIdSipReceiveTCPMessageWait.Trigger;
begin
  if Self.Message.IsRequest then
    Self.Listeners.NotifyListenersOfRequest(Self.Message as TIdSipRequest,
                                            Self.ReceivedFrom)
  else
    Self.Listeners.NotifyListenersOfResponse(Self.Message as TIdSipResponse,
                                             Self.ReceivedFrom);
end;

//******************************************************************************
//* TIdSipTLSTransport                                                         *
//******************************************************************************
//* TIdSipTLSTransport Public methods ******************************************

class function TIdSipTLSTransport.DefaultPort: Cardinal;
begin
  Result := IdPORT_SIPS;
end;

class function TIdSipTLSTransport.GetTransportType: String;
begin
  Result := TlsTransport;
end;

class function TIdSipTLSTransport.IsSecure: Boolean;
begin
  Result := true;
end;

class function TIdSipTLSTransport.SrvPrefix: String;
begin
  Result := SrvTlsPrefix;
end;

//* TIdSipTLSTransport Protected methods ***************************************

function TIdSipTLSTransport.ServerType: TIdSipTcpServerClass;
begin
  Result := TIdSipTlsServer;
end;

//* TIdSipTLSTransport Private methods *****************************************

function TIdSipTLSTransport.GetOnGetPassword: TPasswordEvent;
begin
  Result := Self.TLS.OnGetPassword;
end;

function TIdSipTLSTransport.GetRootCertificate: TFileName;
begin
  Result := Self.TLS.RootCertificate;
end;

function TIdSipTLSTransport.GetServerCertificate: TFileName;
begin
  Result := Self.TLS.ServerCertificate;
end;

function TIdSipTLSTransport.GetServerKey: TFileName;
begin
  Result := Self.TLS.ServerKey;
end;

function TIdSipTLSTransport.TLS: TIdSipTlsServer;
begin
  Result := Self.Transport as TIdSipTlsServer;
end;

procedure TIdSipTLSTransport.SetOnGetPassword(Value: TPasswordEvent);
begin
  Self.TLS.OnGetPassword := Value;
end;

procedure TIdSipTLSTransport.SetRootCertificate(Value: TFileName);
begin
  Self.TLS.RootCertificate := Value;
end;

procedure TIdSipTLSTransport.SetServerCertificate(Value: TFileName);
begin
  Self.TLS.ServerCertificate := Value;
end;

procedure TIdSipTLSTransport.SetServerKey(Value: TFileName);
begin
  Self.TLS.ServerKey := Value;
end;

//******************************************************************************
//* TIdSipSCTPTransport                                                        *
//******************************************************************************
//* TIdSipSCTPTransport Public methods *****************************************

class function TIdSipSCTPTransport.GetTransportType: String;
begin
  Result := SctpTransport;
end;

class function TIdSipSCTPTransport.SrvPrefix: String;
begin
  Result := SrvSctpPrefix;
end;

//******************************************************************************
//* TIdSipUDPTransport                                                         *
//******************************************************************************
//* TIdSipUDPTransport Public methods ******************************************

class function TIdSipUDPTransport.GetTransportType: String;
begin
  Result := UdpTransport;
end;

class function TIdSipUDPTransport.SrvPrefix: String;
begin
  Result := SrvUdpPrefix;
end;

constructor TIdSipUDPTransport.Create;
begin
  inherited Create;

  Self.Bindings.Add;
end;

function TIdSipUDPTransport.IsReliable: Boolean;
begin
  Result := false;
end;

procedure TIdSipUDPTransport.Start;
begin
  Self.Transport.Active := true;
end;

procedure TIdSipUDPTransport.Stop;
begin
  Self.Transport.Active := false;
end;

//* TIdSipUDPTransport Protected methods ***************************************

procedure TIdSipUDPTransport.ChangeBinding(const Address: String; Port: Cardinal);
var
  Binding: TIdSocketHandle;
begin
  Self.Stop;

  Self.Transport.Bindings.Clear;
  Self.Bindings.DefaultPort := Port;
  Binding := Self.Bindings.Add;
  Binding.IP   := Address;
  Binding.Port := Port;

  Self.Start;
end;

procedure TIdSipUDPTransport.DestroyServer;
begin
  Self.Transport.Free;
end;

function TIdSipUDPTransport.GetAddress: String;
begin
  Result := Self.Bindings[0].IP;
end;

function TIdSipUDPTransport.GetBindings: TIdSocketHandles;
begin
  Result := Self.Transport.Bindings;
end;

function TIdSipUDPTransport.GetPort: Cardinal;
begin
  Result := Self.Transport.DefaultPort;
end;

procedure TIdSipUDPTransport.InstantiateServer;
begin
  Self.Transport := TIdSipUdpServer.Create(nil);
  Self.Transport.AddMessageListener(Self);
  Self.Transport.ThreadedEvent := true;
end;

procedure TIdSipUDPTransport.OnReceiveRequest(Request: TIdSipRequest;
                                              ReceivedFrom: TIdSipConnectionBindings);
begin
  // RFC 3581 section 4
  if Request.LastHop.HasRPort then begin
    if not Request.LastHop.HasReceived then
      Request.LastHop.Received := ReceivedFrom.PeerIP;

    Request.LastHop.RPort := ReceivedFrom.PeerPort;
  end;

  inherited OnReceiveRequest(Request, ReceivedFrom);
end;

procedure TIdSipUDPTransport.SendRequest(R: TIdSipRequest;
                                         Dest: TIdSipLocation);
begin
  inherited SendRequest(R, Dest);

  Self.Transport.Send(Dest.IPAddress,
                      Dest.Port,
                      R.AsString);
end;

procedure TIdSipUDPTransport.SendResponse(R: TIdSipResponse;
                                          Dest: TIdSipLocation);
begin
  inherited SendResponse(R, Dest);

  // cf RFC 3581 section 4.
  // TODO: this isn't quite right. We have to send the response (if that's what
  // the message is) from the ip/port that the request was received on.

  Self.Transport.Send(Dest.IPAddress,
                      Dest.Port,
                      R.AsString);
end;

procedure TIdSipUDPTransport.SetTimer(Value: TIdTimerQueue);
begin
  inherited SetTimer(Value);

  Self.Transport.Timer := Value;
end;

//******************************************************************************
//* TIdSipTransports                                                           *
//******************************************************************************
//* TIdSipTransports Public methods ********************************************

constructor TIdSipTransports.Create;
begin
  inherited Create;

  Self.List := TObjectList.Create(true);
end;

destructor TIdSipTransports.Destroy;
begin
  Self.List.Free;

  inherited Destroy;
end;

procedure TIdSipTransports.Add(T: TIdSipTransport);
begin
  Self.List.Add(T);
end;

procedure TIdSipTransports.Clear;
begin
  Self.List.Clear;
end;

function TIdSipTransports.Count: Integer;
begin
  Result := Self.List.Count;
end;

//* TIdSipTransports Private methods *******************************************

function TIdSipTransports.GetTransports(Index: Integer): TIdSipTransport;
begin
  Result := Self.List[Index] as TIdSipTransport;
end;

//******************************************************************************
//* TIdSipConnectionTableEntry                                                 *
//******************************************************************************
//* TIdSipConnectionTableEntry Public methods **********************************

constructor TIdSipConnectionTableEntry.Create(Connection:    TIdTCPConnection;
                                              CopyOfRequest: TIdSipRequest);
begin
  inherited Create;

  Self.fConnection := Connection;
  Self.fRequest := TIdSipRequest.Create;
  Self.fRequest.Assign(CopyOfRequest);
end;

destructor TIdSipConnectionTableEntry.Destroy;
begin
  Self.fRequest.Free;

  inherited Destroy;
end;

//******************************************************************************
//* TIdSipConnectionTable                                                      *
//******************************************************************************
//* TIdSipConnectionTable Public methods ***************************************

constructor TIdSipConnectionTable.Create;
begin
  inherited Create;

  Self.List := TObjectList.Create(true);
end;

destructor TIdSipConnectionTable.Destroy;
begin
  Self.List.Free;

  inherited Destroy;
end;

procedure TIdSipConnectionTable.Add(Connection: TIdTCPConnection;
                                    Request:    TIdSipRequest);
begin
  Self.List.Add(TIdSipConnectionTableEntry.Create(Connection, Request));
  Connection.OnDisconnected := Self.ConnectionDisconnected;
end;

function TIdSipConnectionTable.ConnectionFor(Msg: TIdSipMessage): TIdTCPConnection;
var
  Count: Integer;
  I:     Integer;
  Found: Boolean;
begin
  Result := nil;

  I := 0;
  Count := Self.List.Count;
  Found := false;
  while (I < Count) and not Found do begin
    if Msg.IsRequest then
      Found := Self.EntryAt(I).Request.Equals(Msg)
    else
      Found := Self.EntryAt(I).Request.Match(Msg);

    if not Found then
      Inc(I);
  end;

  if (I < Count) then
    Result := Self.EntryAt(I).Connection;
end;

function TIdSipConnectionTable.ConnectionFor(Destination: TIdSipLocation): TIdTCPConnection;
var
  Count: Integer;
  I:     Integer;
  Found: Boolean;
begin
  Result := nil;

  I := 0;
  Count := Self.List.Count;
  Found := false;
  while (I < Count) and not Found do begin
    Found := (Destination.Transport = TcpTransport)
         and (Destination.IPAddress = Self.EntryAt(I).Connection.Socket.Binding.PeerIP)
         and (Integer(Destination.Port) = Self.EntryAt(I).Connection.Socket.Binding.PeerPort);

    if not Found then
      Inc(I);
  end;

  if (I < Count) then
    Result := Self.EntryAt(I).Connection;
end;

function TIdSipConnectionTable.Count: Integer;
begin
  Result := Self.List.Count;
end;

procedure TIdSipConnectionTable.Remove(Connection: TIdTCPConnection);
var
  Count: Integer;
  I: Integer;
begin
  I := 0;
  Count := Self.List.Count;
  while (I < Count)
    and (Self.EntryAt(I).Connection <> Connection) do
    Inc(I);

  if (I < Count) then
    Self.List.Delete(I);
end;

//* TIdSipConnectionTable Private methods **************************************

procedure TIdSipConnectionTable.ConnectionDisconnected(Sender: TObject);
begin
  Self.Remove(Sender as TIdTCPConnection);
end;

function TIdSipConnectionTable.EntryAt(Index: Integer): TIdSipConnectionTableEntry;
begin
  Result := Self.List[Index] as TIdSipConnectionTableEntry;
end;

//******************************************************************************
//* TIdSipConnectionTableLock                                                  *
//******************************************************************************
//* TIdSipConnectionTableLock Public methods ***********************************

constructor TIdSipConnectionTableLock.Create;
begin
  inherited Create;

  Self.Lock  := TCriticalSection.Create;
  Self.Table := TIdSipConnectionTable.Create;
end;

destructor TIdSipConnectionTableLock.Destroy;
begin
  Self.Lock.Acquire;
  try
    Self.Table.Free;
  finally
    Self.Lock.Release;
  end;
  Self.Lock.Free;

  inherited Destroy;
end;

function TIdSipConnectionTableLock.LockList: TIdSipConnectionTable;
begin
  Self.Lock.Acquire;
  Result := Self.Table;
end;

procedure TIdSipConnectionTableLock.UnlockList;
begin
  Self.Lock.Release;
end;

//******************************************************************************
//* TIdSipTransportExceptionMethod                                             *
//******************************************************************************
//* TIdSipTransportExceptionMethod Public methods ******************************

procedure TIdSipTransportExceptionMethod.Run(const Subject: IInterface);
begin
  (Subject as IIdSipTransportListener).OnException(Self.Exception,
                                                   Self.Reason);
end;

//******************************************************************************
//* TIdSipTransportReceiveRequestMethod                                        *
//******************************************************************************
//* TIdSipTransportReceiveRequestMethod Public methods *************************

procedure TIdSipTransportReceiveRequestMethod.Run(const Subject: IInterface);
begin
  (Subject as IIdSipTransportListener).OnReceiveRequest(Self.Request,
                                                        Self.Receiver);
end;

//******************************************************************************
//* TIdSipTransportReceiveResponseMethod                                       *
//******************************************************************************
//* TIdSipTransportReceiveResponseMethod Public methods ************************

procedure TIdSipTransportReceiveResponseMethod.Run(const Subject: IInterface);
begin
  (Subject as IIdSipTransportListener).OnReceiveResponse(Self.Response,
                                                         Self.Receiver);
end;

//******************************************************************************
//* TIdSipTransportRejectedMessageMethod                                       *
//******************************************************************************
//* TIdSipTransportRejectedMessageMethod Public methods ************************

procedure TIdSipTransportRejectedMessageMethod.Run(const Subject: IInterface);
begin
  (Subject as IIdSipTransportListener).OnRejectedMessage(Self.Msg,
                                                         Self.Reason);
end;

//******************************************************************************
//* TIdSipTransportSendingRequestMethod                                        *
//******************************************************************************
//* TIdSipTransportSendingRequestMethod Public methods *************************

procedure TIdSipTransportSendingRequestMethod.Run(const Subject: IInterface);
begin
  (Subject as IIdSipTransportSendingListener).OnSendRequest(Self.Request,
                                                            Self.Sender);
end;

//******************************************************************************
//* TIdSipTransportSendingResponseMethod                                       *
//******************************************************************************
//* TIdSipTransportSendingResponseMethod Public methods ************************

procedure TIdSipTransportSendingResponseMethod.Run(const Subject: IInterface);
begin
  (Subject as IIdSipTransportSendingListener).OnSendResponse(Self.Response,
                                                             Self.Sender);
end;

//******************************************************************************
//* EIdSipTransport                                                            *
//******************************************************************************
//* EIdSipTransport Public methods *********************************************

constructor EIdSipTransport.Create(Transport: TIdSipTransport;
                                   SipMessage: TIdSipMessage;
                                   const Msg: String);
begin
  inherited Create(Msg);

  Self.fSipMessage := SipMessage;
  Self.fTransport  := Transport;
end;

initialization
  GTransportTypes := TStringList.Create;
finalization
// These objects are purely memory-based, so it's safe not to free them here.
// Still, perhaps we need to review this methodology. How else do we get
// something like class variables?
//  GTransportTypes.Free;
end.
