unit SpikeClient;

interface

uses
  Classes, Controls, ExtCtrls, Forms, IdSipCore, IdSipMessage, IdSipTransaction,
  IdSipTransport, StdCtrls;

type
  TSpike = class(TForm,
                 IIdSipSessionListener,
                 IIdSipTransportListener,
                 IIdSipTransportSendingListener)
    Panel1: TPanel;
    Invite: TButton;
    Log: TMemo;
    Bye: TButton;
    procedure InviteClick(Sender: TObject);
    procedure ByeClick(Sender: TObject);
  private
    UA:      TIdSipUserAgentCore;
    Session: TIdSipSession;
    Tran:    TIdSipTransport;

    procedure LogMessage(const Msg: TIdSipMessage);
    procedure OnEstablishedSession(const Session: TIdSipSession);
    procedure OnEndedSession(const Session: TIdSipSession);
    procedure OnModifiedSession(const Session: TIdSipSession;
                                const Invite: TIdSipRequest);
    procedure OnNewSession(const Session: TIdSipSession);
    procedure OnReceiveRequest(const Request: TIdSipRequest;
                               const Transport: TIdSipTransport);
    procedure OnReceiveResponse(const Response: TIdSipResponse;
                                const Transport: TIdSipTransport);
    procedure OnSendRequest(const Request: TIdSipRequest;
                            const Transport: TIdSipTransport);
    procedure OnSendResponse(const Response: TIdSipResponse;
                             const Transport: TIdSipTransport);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;

var
  Spike: TSpike;

implementation

{$R *.dfm}

uses
  Dialogs, IdSipConsts, IdSipHeaders, IdStack, IdTcpClient, IdURI, SysUtils;

constructor TSpike.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

//  Self.Bye.Enabled := false;

  UA := TIdSipUserAgentCore.Create;
  UA.Dispatcher := TIdSipTransactionDispatcher.Create;

  Tran := TIdSipUDPTransport.Create(IdPORT_SIP + 10000);
  Tran.Bindings.Add.IP := GStack.LocalAddress;
  Tran.HostName := 'wsfrank';
  Tran.AddTransportListener(Self);
  Tran.AddTransportSendingListener(Self);
  UA.Dispatcher.AddTransport(Tran);

  UA.From.Address.URI := 'sip:franks' + '@' + Tran.HostName + ':' + IntToStr(Tran.Bindings[0].Port);
  UA.From.Tag         := '1';
  UA.Contact.Address  := UA.From.Address;
  UA.HostName := Tran.HostName;

  UA.AddSessionListener(Self);

  Tran.Start;
end;

destructor TSpike.Destroy;
begin
  Tran.Free;
  UA.Dispatcher.Free;
  UA.Free;

  inherited Destroy;
end;

procedure TSpike.InviteClick(Sender: TObject);
var
  ToHeader: TIdSipToHeader;
begin
  ToHeader := TIdSipToHeader.Create;
  try
    ToHeader.Value := 'sip:franks@127.0.0.1';

    Self.Session := UA.Call(ToHeader);
  finally
    ToHeader.Free;
  end;

//  Self.Invite.Enabled := false;
//  Self.Bye.Enabled := true;
end;

procedure TSpike.LogMessage(const Msg: TIdSipMessage);
begin
  Self.Log.Lines.Add(Msg.AsString);
  Self.Log.Lines.Add('----');
end;

procedure TSpike.OnEstablishedSession(const Session: TIdSipSession);
begin
//  Self.Bye.Enabled := true;
end;

procedure TSpike.OnEndedSession(const Session: TIdSipSession);
begin
  Self.Session := nil;
end;

procedure TSpike.OnModifiedSession(const Session: TIdSipSession;
                                   const Invite: TIdSipRequest);
begin
end;

procedure TSpike.OnNewSession(const Session: TIdSipSession);
begin
//  Self.Bye.Enabled := true;
end;

procedure TSpike.OnReceiveRequest(const Request: TIdSipRequest;
                                  const Transport: TIdSipTransport);
begin
  Self.LogMessage(Request);
end;

procedure TSpike.OnReceiveResponse(const Response: TIdSipResponse;
                                   const Transport: TIdSipTransport);
begin
  Self.LogMessage(Response);
end;

procedure TSpike.OnSendRequest(const Request: TIdSipRequest;
                               const Transport: TIdSipTransport);
begin
  Self.LogMessage(Request);
end;

procedure TSpike.OnSendResponse(const Response: TIdSipResponse;
                                const Transport: TIdSipTransport);
begin
  Self.LogMessage(Response);
end;

procedure TSpike.ByeClick(Sender: TObject);
begin
  if Assigned(Self.Session) then
    Self.Session.Terminate;

//  Self.Bye.Enabled := false;
//  Self.Invite.Enabled := true;
end;

end.
