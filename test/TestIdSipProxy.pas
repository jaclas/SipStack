unit TestIdSipProxy;

interface

uses
  IdSipCore, IdSipMessage, IdSipMockTransactionDispatcher, IdSipProxy,
  TestFramework;

type
  TestTIdSipProxy = class(TTestCase)
  private
    Client:           TIdSipUserAgentCore;
    ClientDispatcher: TIdSipMockTransactionDispatcher;
    Dispatcher:       TIdSipMockTransactionDispatcher;
    Invite:           TIdSipRequest;
    Proxy:            TIdSipProxy;

    function  CreateAuthorizedRequest(OriginalRequest: TIdSipRequest;
                                      Challenge: TIdSipResponse): TIdSipRequest;
    procedure RemoveBody(Msg: TIdSipMessage);
    procedure SimulateRemoteInvite;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAuthorization;
    procedure TestRejectUnauthorizedRequest;
  end;

implementation

uses
  IdSipConsts, TestFrameworkSip, IdSipMockTransport, SysUtils;

function Suite: ITestSuite;
begin
  Result := TTestSuite.Create('IdSipProxy unit tests');
  Result.AddTest(TestTIdSipProxy.Suite);
end;

//******************************************************************************
//* TestTIdSipProxy                                                            *
//******************************************************************************
//* TestTIdSipProxy Public methods *********************************************

procedure TestTIdSipProxy.SetUp;
begin
  inherited SetUp;

  Self.Dispatcher := TIdSipMockTransactionDispatcher.Create;
  Self.Dispatcher.Transport.LocalEchoMessages := false;
  Self.Dispatcher.Transport.TransportType := sttTCP;

  Self.Invite := TIdSipTestResources.CreateBasicRequest;
  Self.RemoveBody(Self.Invite);

  Self.Proxy := TIdSipProxy.Create;
  Self.Proxy.Dispatcher := Self.Dispatcher;
  Self.Dispatcher.AddUnhandledMessageListener(Self.Proxy);

  Self.Client := TIdSipUserAgentCore.Create;
  Self.ClientDispatcher := TIdSipMockTransactionDispatcher.Create;
  Self.Client.Dispatcher := Self.ClientDispatcher;
end;

procedure TestTIdSipProxy.TearDown;
begin
  Self.ClientDispatcher.Free;
  Self.Client.Free;
  Self.Proxy.Free;
  Self.Invite.Free;
  Self.Dispatcher.Free;

  inherited TearDown;
end;

//* TestTIdSipProxy Private methods ********************************************

function TestTIdSipProxy.CreateAuthorizedRequest(OriginalRequest: TIdSipRequest;
                                                 Challenge: TIdSipResponse): TIdSipRequest;
begin
  Result := OriginalRequest.Copy as TIdSipRequest;
  try
  except
    FreeAndNil(Result);
    raise;
  end;
end;

procedure TestTIdSipProxy.RemoveBody(Msg: TIdSipMessage);
begin
  Msg.RemoveAllHeadersNamed(ContentTypeHeaderFull);
  Msg.Body := '';
  Msg.ToHeader.Value := Msg.ToHeader.DisplayName
                               + ' <' + Msg.ToHeader.Address.URI + '>';
  Msg.RemoveAllHeadersNamed(ContentTypeHeaderFull);
  Msg.ContentLength := 0;
end;

procedure TestTIdSipProxy.SimulateRemoteInvite;
begin
  Self.Dispatcher.Transport.FireOnRequest(Self.Invite);
end;

//* TestTIdSipProxy Published methods ******************************************

procedure TestTIdSipProxy.TestAuthorization;
var
  Response:      TIdSipResponse;
  ResponseCount: Cardinal;
  Retry:         TIdSipRequest;
begin
  Self.Proxy.RequireAuthentication := true;

  ResponseCount := Self.Dispatcher.Transport.SentResponseCount;
  Self.SimulateRemoteInvite;

  Check(ResponseCount < Self.Dispatcher.Transport.SentResponseCount,
        'No response sent');

  Response := Self.Dispatcher.Transport.LastResponse;

  Retry := Self.CreateAuthorizedRequest(Self.Invite, Response);
  try
    ResponseCount := Self.Dispatcher.Transport.SentResponseCount;

    Self.Dispatcher.Transport.FireOnRequest(Retry);

    Check(ResponseCount < Self.Dispatcher.Transport.SentResponseCount,
          'No response sent after re-attempt');
  finally
    Retry.Free;
  end;
end;

procedure TestTIdSipProxy.TestRejectUnauthorizedRequest;
var
  Response:      TIdSipResponse;
  ResponseCount: Cardinal;
begin
  Self.Proxy.RequireAuthentication := true;

  ResponseCount := Self.Dispatcher.Transport.SentResponseCount;
  Self.SimulateRemoteInvite;

  Check(ResponseCount < Self.Dispatcher.Transport.SentResponseCount,
        'No response sent');

  Response := Self.Dispatcher.Transport.LastResponse;
  CheckEquals(SIPProxyAuthenticationRequired,
              Response.StatusCode,
              'Unexpected response');
  Check(Response.HasProxyAuthenticate,
        'No Proxy-Authenticate header');
end;

initialization
  RegisterTest('Proxy', Suite);
end.
