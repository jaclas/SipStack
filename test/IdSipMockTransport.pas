{
  (c) 2004 Directorate of New Technologies, Royal National Institute for Deaf people (RNID)

  The RNID licence covers this unit. Read the licence at:
      http://www.ictrnid.org.uk/docs/gw/rnid_license.txt

  This unit contains code written by:
    * Frank Shearar
}
unit IdSipMockTransport;

interface

uses
  IdSipMessage, IdSipTransport, IdSocketHandle, SysUtils;

type
  TIdSipMockTransport = class(TIdSipTransport)
  private
    fACKCount:           Cardinal;
    fAddress:            String;
    fBindings:           TIdSocketHandles;
    fFailWith:           ExceptClass;
    fLastACK:            TIdSipRequest;
    fLastRequest:        TIdSipRequest;
    fLastResponse:       TIdSipResponse;
    fLocalEchoMessages:  Boolean;
    fPort:               Cardinal;
    fSecondLastResponse: TIdSipResponse;
    fSentRequestCount:   Cardinal;
    fSentResponseCount:  Cardinal;
    fTransportType:      TIdSipTransportType;
  protected
    procedure ChangeBinding(const Address: String; Port: Cardinal); override;
    function  GetAddress: String; override;
    function  GetBindings: TIdSocketHandles; override;
    function  GetPort: Cardinal; override;
    procedure SendRequest(R: TIdSipRequest); override;
    procedure SendResponse(R: TIdSipResponse); override;
    function  SentByIsRecognised(Via: TIdSipViaHeader): Boolean; override;
  public
    constructor Create; override;
    destructor  Destroy; override;

    procedure FireOnRequest(R: TIdSipRequest);
    procedure FireOnResponse(R: TIdSipResponse);
    function  GetTransportType: TIdSipTransportType; override;
    function  IsReliable: Boolean; override;
    function  IsSecure: Boolean; override;
    procedure RaiseException(E: ExceptClass);
    procedure ResetACKCount;
    procedure ResetSentRequestCount;
    procedure ResetSentResponseCount;
    procedure Start; override;
    procedure Stop; override;

    property ACKCount:           Cardinal            read fACKCount;
    property FailWith:           ExceptClass         read fFailWith write fFailWith;
    property LastACK:            TIdSipRequest       read fLastACK;
    property LastRequest:        TIdSipRequest       read fLastRequest;
    property LastResponse:       TIdSipResponse      read fLastResponse;
    property LocalEchoMessages:  Boolean             read fLocalEchoMessages write fLocalEchoMessages;
    property SecondLastResponse: TIdSipResponse      read fSecondLastResponse;
    property SentRequestCount:   Cardinal            read fSentRequestCount;
    property SentResponseCount:  Cardinal            read fSentResponseCount;
    property TransportType:      TIdSipTransportType read fTransportType write fTransportType;
  end;

implementation

//******************************************************************************
//* TIdSipMockTransport                                                        *
//******************************************************************************
//* TIdSipMockTransport Public methods *****************************************

constructor TIdSipMockTransport.Create;
begin
  inherited Create;

  Self.ResetSentRequestCount;
  Self.fBindings           := TIdSocketHandles.Create(nil);
  Self.fLastACK            := TIdSipRequest.Create;
  Self.fLastRequest        := TIdSipRequest.Create;
  Self.fLastResponse       := TIdSipResponse.Create;
  Self.fSecondLastResponse := TIdSipResponse.Create;

  Self.LocalEchoMessages := false;
end;

destructor TIdSipMockTransport.Destroy;
begin
  Self.SecondLastResponse.Free;
  Self.LastResponse.Free;
  Self.LastRequest.Free;
  Self.LastACK.Free;
  Self.Bindings.Free;

  inherited Destroy;
end;

procedure TIdSipMockTransport.FireOnRequest(R: TIdSipRequest);
begin
  Self.NotifyTransportListeners(R);

  Self.LastRequest.Assign(R);
end;

procedure TIdSipMockTransport.FireOnResponse(R: TIdSipResponse);
begin
  Self.NotifyTransportListeners(R);

  Self.LastResponse.Assign(R);
end;

function TIdSipMockTransport.GetTransportType: TIdSipTransportType;
begin
  Result := Self.TransportType;
end;

function TIdSipMockTransport.IsReliable: Boolean;
begin
  Result := Self.TransportType <> sttUDP;
end;

function TIdSipMockTransport.IsSecure: Boolean;
begin
  Result := Self.TransportType = sttTLS;
end;

procedure TIdSipMockTransport.RaiseException(E: ExceptClass);
begin
  raise E.Create('TIdSipMockTransport');
end;

procedure TIdSipMockTransport.ResetACKCount;
begin
  Self.fACKCount := 0;
end;

procedure TIdSipMockTransport.ResetSentRequestCount;
begin
  Self.fSentRequestCount := 0;
end;

procedure TIdSipMockTransport.ResetSentResponseCount;
begin
  Self.fSentResponseCount := 0;
end;

procedure TIdSipMockTransport.Start;
begin
end;

procedure TIdSipMockTransport.Stop;
begin
end;

//* TIdSipMockTransport Protected methods **************************************

procedure TIdSipMockTransport.ChangeBinding(const Address: String; Port: Cardinal);
begin
  Self.fAddress := Address;
  Self.fPort    := Port;
end;

function TIdSipMockTransport.GetAddress: String;
begin
  Result := Self.fAddress;
end;

function TIdSipMockTransport.GetBindings: TIdSocketHandles;
begin
  Result := Self.fBindings;
end;

function TIdSipMockTransport.GetPort: Cardinal;
begin
  Result := Self.fPort;
end;

procedure TIdSipMockTransport.SendRequest(R: TIdSipRequest);
begin
  inherited SendRequest(R);

  if R.IsAck then
    Self.LastACK.Assign(R);

  Self.LastRequest.Assign(R);

  if Assigned(Self.FailWith) then
    raise EIdSipTransport.Create(Self,
                                 R,
                                 'TIdSipMockTransport.SendRequest ('
                               + Self.FailWith.ClassName + ')');

  if R.IsAck then
    Inc(Self.fACKCount)
  else
    Inc(Self.fSentRequestCount);

  if Self.LocalEchoMessages then
    Self.NotifyTransportListeners(R);
end;

procedure TIdSipMockTransport.SendResponse(R: TIdSipResponse);
begin
  inherited SendResponse(R);

  Self.SecondLastResponse.Assign(Self.LastResponse);
  Self.LastResponse.Assign(R);

  if Assigned(Self.FailWith) then
    raise EIdSipTransport.Create(Self,
                                 R,
                                 'TIdSipMockTransport.SendResponse ('
                               + Self.FailWith.ClassName + ')');

  Inc(Self.fSentResponseCount);

  if Self.LocalEchoMessages then
    Self.NotifyTransportListeners(R);
end;

function TIdSipMockTransport.SentByIsRecognised(Via: TIdSipViaHeader): Boolean;
begin
  Result := true;
end;

end.
