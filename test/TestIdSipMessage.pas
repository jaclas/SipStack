{
  (c) 2004 Directorate of New Technologies, Royal National Institute for Deaf people (RNID)

  The RNID licence covers this unit. Read the licence at:
      http://www.ictrnid.org.uk/docs/gw/rnid_license.txt

  This unit contains code written by:
    * Frank Shearar
}
unit TestIdSipMessage;

interface

uses
  IdSipDialogID, IdSipMessage, SysUtils, TestFramework, TestFrameworkSip;

type
  TestFunctions = class(TTestCase)
  published
    procedure TestDecodeQuotedStr;
    procedure TestFirstChar;
    procedure TestIsEqual;
    procedure TestLastChar;
    procedure TestShortMonthToInt;
    procedure TestWithoutFirstAndLastChars;
  end;

  TIdSipTrivialMessage = class(TIdSipMessage)
  protected
    function  FirstLine: String; override;
    function  MatchRequest(Request: TIdSipRequest;
                           UseCSeqMethod: Boolean = true): Boolean; override;
    procedure ParseStartLine(Parser: TIdSipParser); override;
  public
    function  Equals(Msg: TIdSipMessage): Boolean; override;
    function  IsRequest: Boolean; override;
    function  MalformedException: EBadMessageClass; override;
  end;

  TestTIdSipMessage = class(TTestCaseSip)
  private
    Msg: TIdSipMessage;

  protected
    procedure AddRequiredHeaders(Msg: TIdSipMessage);
    procedure CheckBasicMessage(Msg: TIdSipMessage;
                                CheckBody: Boolean = true);
    function  MessageType: TIdSipMessageClass; virtual; abstract;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAddHeader;
    procedure TestAddHeaderName;
    procedure TestAddHeaders;
    procedure TestAssignCopiesBody;
    procedure TestClearHeaders;
    procedure TestContactCount;
    procedure TestFirstContact;
    procedure TestFirstExpires;
    procedure TestFirstHeader;
    procedure TestFirstMinExpires;
    procedure TestFirstRequire;
    procedure TestHasExpiry;
    procedure TestIsMalformedContentLength;
    procedure TestIsMalformedMalformedHeader;
    procedure TestIsMalformedMissingContentType;
    procedure TestIsMalformedMissingCallID;
    procedure TestIsMalformedMissingCseq;
    procedure TestIsMalformedMissingFrom;
    procedure TestIsMalformedMissingTo;
    procedure TestIsMalformedMissingVia;
    procedure TestHeaderCount;
    procedure TestLastHop;
    procedure TestQuickestExpiry;
    procedure TestQuickestExpiryNoExpires;
    procedure TestReadBody;
    procedure TestReadBodyWithZeroContentLength;
    procedure TestRemoveHeader;
    procedure TestRemoveHeaders;
    procedure TestSetCallID;
    procedure TestSetContacts;
    procedure TestSetContentLanguage;
    procedure TestSetContentLength;
    procedure TestSetContentType;
    procedure TestSetCSeq;
    procedure TestSetFrom;
    procedure TestSetPath;
    procedure TestSetRecordRoute;
    procedure TestSetSipVersion;
    procedure TestSetTo;
    procedure TestWillEstablishDialog;
  end;

  TestTIdSipRequest = class(TestTIdSipMessage)
  private
    Request:  TIdSipRequest;
    Response: TIdSipResponse;

    procedure CheckBasicRequest(Msg: TIdSipMessage;
                                CheckBody: Boolean = true);
  protected
    function MessageType: TIdSipMessageClass; override;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAckForEstablishingDialog;
    procedure TestAckFor;
    procedure TestAckForWithAuthentication;
    procedure TestAckForWithRoute;
    procedure TestAddressOfRecord;
    procedure TestAssign;
    procedure TestAssignBad;
    procedure TestAsString;
    procedure TestAsStringNoMaxForwardsSet;
    procedure TestCopy;
    procedure TestCreateCancel;
    procedure TestCreateCancelANonInviteRequest;
    procedure TestCreateCancelWithProxyRequire;
    procedure TestCreateCancelWithRequire;
    procedure TestCreateCancelWithRoute;
    procedure TestFirstAuthorization;
    procedure TestFirstProxyAuthorization;
    procedure TestFirstProxyRequire;
    procedure TestHasSipsUri;
    procedure TestIsMalformedCSeqMethod;
    procedure TestIsMalformedSipVersion;
    procedure TestIsMalformedMethod;
    procedure TestIsMalformedMissingVia;
    procedure TestIsAck;
    procedure TestIsBye;
    procedure TestIsCancel;
    procedure TestEqualsComplexMessages;
    procedure TestEqualsDifferentHeaders;
    procedure TestEqualsDifferentMethod;
    procedure TestEqualsDifferentRequestUri;
    procedure TestEqualsDifferentSipVersion;
    procedure TestEqualsFromAssign;
    procedure TestEqualsResponse;
    procedure TestEqualsTrivial;
    procedure TestHasAuthorization;
    procedure TestHasProxyAuthorization;
    procedure TestIsInvite;
    procedure TestIsOptions;
    procedure TestIsRegister;
    procedure TestIsRequest;
    procedure TestMatchRFC2543Options;
    procedure TestMatchRFC2543Cancel;
    procedure TestMatchCancel;
    procedure TestMatchCancelAgainstAck;
    procedure TestNewRequestHasContentLength;
    procedure TestParse;
    procedure TestParseCompoundHeader;
    procedure TestParseFoldedHeader;
    procedure TestParseLeadingBlankLines;
    procedure TestParseMalformedRequestLine;
    procedure TestParseWithRequestUriInAngleBrackets;
    procedure TestRequiresResponse;
    procedure TestSetMaxForwards;
    procedure TestSetRoute;
  end;

  TestTIdSipResponse = class(TestTIdSipMessage)
  private
    Contact:  TIdSipContactHeader;
    Request:  TIdSipRequest;
    Response: TIdSipResponse;

    procedure CheckBasicResponse(Msg: TIdSipMessage;
                                 CheckBody: Boolean = true);
  protected
    function MessageType: TIdSipMessageClass; override;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAssign;
    procedure TestAssignBad;
    procedure TestAsString;
    procedure TestCopy;
    procedure TestEqualsComplexMessages;
    procedure TestEqualsDifferentHeaders;
    procedure TestEqualsDifferentSipVersion;
    procedure TestEqualsDifferentStatusCode;
    procedure TestEqualsDifferentStatusText;
    procedure TestEqualsRequest;
    procedure TestEqualsTrivial;
    procedure TestFirstProxyAuthenticate;
    procedure TestFirstUnsupported;
    procedure TestFirstWarning;
    procedure TestFirstWWWAuthenticate;
    procedure TestHasAuthenticationInfo;
    procedure TestHasProxyAuthenticate;
    procedure TestHasWarning;
    procedure TestHasWWWAuthenticate;
    procedure TestInResponseToRecordRoute;
    procedure TestInResponseToSipsRecordRoute;
    procedure TestInResponseToSipsRequestUri;
    procedure TestInResponseToTryingWithTimestamps;
    procedure TestInResponseToWithContact;
    procedure TestIsAuthenticationChallenge;
    procedure TestIsMalformedStatusCode;
    procedure TestIsFinal;
    procedure TestIsOK;
    procedure TestIsProvisional;
    procedure TestIsRedirect;
    procedure TestIsRequest;
    procedure TestIsTrying;
    procedure TestParse;
    procedure TestParseEmptyString;
    procedure TestParseFoldedHeader;
    procedure TestParseLeadingBlankLines;
  end;

  TestTIdSipResponseList = class(TTestCase)
  private
    List: TIdSipResponseList;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAddAndCount;
    procedure TestDelete;
    procedure TestFirst;
    procedure TestIsEmpty;
    procedure TestLast;
    procedure TestListStoresCopiesNotReferences;
    procedure TestSecondLast;
  end;

implementation

uses
  Classes, IdSimpleParser, IdSipConsts, TestMessages;

const
  AllMethods: array[1..7] of String = (MethodAck, MethodBye, MethodCancel,
      MethodInvite, MethodOptions, MethodParam, MethodRegister);
  AllResponses: array[1..50] of Cardinal = (SIPTrying, SIPRinging,
      SIPCallIsBeingForwarded, SIPQueued, SIPSessionProgess, SIPOK,
      SIPMultipleChoices, SIPMovedPermanently, SIPMovedTemporarily,
      SIPUseProxy, SIPAlternativeService, SIPBadRequest, SIPUnauthorized,
      SIPPaymentRequired, SIPForbidden, SIPNotFound, SIPMethodNotAllowed,
      SIPNotAcceptableClient, SIPProxyAuthenticationRequired,
      SIPRequestTimeout, SIPGone, SIPRequestEntityTooLarge,
      SIPRequestURITooLarge, SIPUnsupportedMediaType, SIPUnsupportedURIScheme,
      SIPBadExtension, SIPExtensionRequired, SIPIntervalTooBrief,
      SIPTemporarilyUnavailable, SIPCallLegOrTransactionDoesNotExist,
      SIPLoopDetected, SIPTooManyHops, SIPAddressIncomplete, SIPAmbiguous,
      SIPBusyHere, SIPRequestTerminated, SIPNotAcceptableHere,
      SIPRequestPending, SIPUndecipherable, SIPInternalServerError,
      SIPNotImplemented, SIPBadGateway, SIPServiceUnavailable,
      SIPServerTimeOut, SIPSIPVersionNotSupported, SIPMessageTooLarge,
      SIPBusyEverywhere, SIPDecline, SIPDoesNotExistAnywhere,
      SIPNotAcceptableGlobal);

function Suite: ITestSuite;
begin
  Result := TTestSuite.Create('IdSipMessage tests (Messages)');
  Result.AddTest(TestFunctions.Suite);
  Result.AddTest(TestTIdSipRequest.Suite);
  Result.AddTest(TestTIdSipResponse.Suite);
  Result.AddTest(TestTIdSipResponseList.Suite);
end;

//******************************************************************************
//* TestFunctions                                                              *
//******************************************************************************
//* TestFunctions Published methods ********************************************

procedure TestFunctions.TestDecodeQuotedStr;
var
  Result: String;
begin
  Check(DecodeQuotedStr('', Result), 'Empty string result');
  CheckEquals('', Result,            'Empty string decoded');

  Check(DecodeQuotedStr('\"', Result), '\" result');
  CheckEquals('"', Result,             '\" decoded');

  Check(DecodeQuotedStr('\\', Result), '\\ result');
  CheckEquals('\', Result,             '\\ decoded');

  Check(DecodeQuotedStr('\a', Result), '\a result');
  CheckEquals('a', Result,             '\a decoded');

  Check(DecodeQuotedStr('foo', Result), 'foo result');
  CheckEquals('foo', Result,            'foo decoded');

  Check(DecodeQuotedStr('\"foo\\\"', Result), '\"foo\\\" result');
  CheckEquals('"foo\"', Result,               '\"foo\\\" decoded');

  Check(not DecodeQuotedStr('\', Result), '\ result');
end;

procedure TestFunctions.TestFirstChar;
begin
  CheckEquals('',  FirstChar(''),   'Empty string');
  CheckEquals('a', FirstChar('ab'), 'ab');
end;

procedure TestFunctions.TestIsEqual;
begin
  Check(    IsEqual('', ''),    'Empty strings');
  Check(not IsEqual('', 'a'),   'Empty string & ''a''');
  Check(    IsEqual('a', 'a'),  '''a'' & ''a''');
  Check(    IsEqual('A', 'a'),  '''A'' & ''a''');
  Check(    IsEqual('a', 'A'),  '''a'' & ''A''');
  Check(    IsEqual('A', 'A'),  '''A'' & ''A''');
  Check(not IsEqual(' a', 'a'), ''' a'' & ''a''');
end;

procedure TestFunctions.TestLastChar;
begin
  CheckEquals('',  LastChar(''),   'Empty string');
  CheckEquals('b', LastChar('ab'), 'ab');
end;

procedure TestFunctions.TestShortMonthToInt;
var
  I: Integer;
begin
  for I := Low(ShortMonthNames) to High(ShortMonthNames) do begin
    CheckEquals(I,
                ShortMonthToInt(ShortMonthNames[I]),
                ShortMonthNames[I]);
    CheckEquals(I,
                ShortMonthToInt(UpperCase(ShortMonthNames[I])),
                UpperCase(ShortMonthNames[I]));
  end;

  try
    ShortMonthToInt('foo');
    Fail('Failed to raise exception on ''foo''');
  except
    on EConvertError do;
  end;
end;

procedure TestFunctions.TestWithoutFirstAndLastChars;
begin
  CheckEquals('',    WithoutFirstAndLastChars(''),      'Empty string');
  CheckEquals('',    WithoutFirstAndLastChars('a'),     'a');
  CheckEquals('',    WithoutFirstAndLastChars('ab'),    'ab');
  CheckEquals('b',   WithoutFirstAndLastChars('abc'),   'abc');
  CheckEquals('abc', WithoutFirstAndLastChars('"abc"'), '"abc"');
  CheckEquals('abc', WithoutFirstAndLastChars('[abc]'), '[abc]');
end;

//******************************************************************************
//* TIdSipTrivialMessage                                                       *
//******************************************************************************
//* TIdSipTrivialMessage Public methods ****************************************

function TIdSipTrivialMessage.Equals(Msg: TIdSipMessage): Boolean;
begin
  Result := false;
end;

function TIdSipTrivialMessage.IsRequest: Boolean;
begin
  Result := false;
end;

function TIdSipTrivialMessage.MalformedException: EBadMessageClass;
begin
  Result := nil;
end;

//* TIdSipTrivialMessage Protected methods *************************************

function TIdSipTrivialMessage.FirstLine: String;
begin
  Result := '';
end;

function TIdSipTrivialMessage.MatchRequest(Request: TIdSipRequest;
                                           UseCSeqMethod: Boolean = true): Boolean;
begin
  Result := false;
end;

procedure TIdSipTrivialMessage.ParseStartLine(Parser: TIdSipParser);
begin
end;

//******************************************************************************
//* TestTIdSipMessage                                                          *
//******************************************************************************
//* TestTIdSipMessage Public methods *******************************************

procedure TestTIdSipMessage.SetUp;
begin
  inherited SetUp;

  Self.Msg := Self.MessageType.Create;
end;

procedure TestTIdSipMessage.TearDown;
begin
  Self.Msg.Free;

  inherited TearDown;
end;

//* TestTIdSipMessage Protected methods ****************************************

procedure TestTIdSipMessage.AddRequiredHeaders(Msg: TIdSipMessage);
begin
  Msg.AddHeader(CallIDHeaderFull).Value := 'foo';
  Msg.AddHeader(CSeqHeader).Value       := '1 foo';
  Msg.AddHeader(FromHeaderFull).Value   := 'sip:foo';
  Msg.AddHeader(ToHeaderFull).Value     := 'sip:foo';
  Msg.AddHeader(ViaHeaderFull).Value    := 'SIP/2.0/UDP foo';
end;

procedure TestTIdSipMessage.CheckBasicMessage(Msg: TIdSipMessage;
                                             CheckBody: Boolean = true);
begin
  CheckEquals('SIP/2.0',                              Msg.SIPVersion,              'SipVersion');
  CheckEquals(29,                                     Msg.ContentLength,           'ContentLength');
  CheckEquals('text/plain',                           Msg.ContentType,             'ContentType');
  CheckEquals('a84b4c76e66710@gw1.leo-ix.org',        Msg.CallID,                  'CallID');
  CheckEquals('Wintermute',                           Msg.ToHeader.DisplayName,    'ToHeader.DisplayName');
  CheckEquals('sip:wintermute@tessier-ashpool.co.luna', Msg.ToHeader.Address.URI,    'ToHeader.Address.GetFullURI');
  CheckEquals(';tag=1928301775',                      Msg.ToHeader.ParamsAsString, 'Msg.ToHeader.ParamsAsString');
  CheckEquals('Case',                                 Msg.From.DisplayName,        'From.DisplayName');
  CheckEquals('sip:case@fried.neurons.org',           Msg.From.Address.URI,        'From.Address.GetFullURI');
  CheckEquals(';tag=1928301774',                      Msg.From.ParamsAsString,     'Msg.From.ParamsAsString');
  CheckEquals(314159,                                 Msg.CSeq.SequenceNo,         'Msg.CSeq.SequenceNo');
  CheckEquals('INVITE',                               Msg.CSeq.Method,             'Msg.CSeq.Method');

  CheckEquals(1,                  Msg.Path.Length,              'Path.Length');
  CheckEquals('SIP/2.0',          Msg.LastHop.SipVersion,       'LastHop.SipVersion');
  Check      (sttTCP =            Msg.LastHop.Transport,        'LastHop.Transport');
  CheckEquals('gw1.leo-ix.org',   Msg.LastHop.SentBy,           'LastHop.SentBy');
  CheckEquals(IdPORT_SIP,         Msg.LastHop.Port,             'LastHop.Port');
  CheckEquals('z9hG4bK776asdhds', Msg.LastHop.Params['branch'], 'LastHop.Params[''branch'']');

  CheckEquals('To: Wintermute <sip:wintermute@tessier-ashpool.co.luna>;tag=1928301775',
              Msg.FirstHeader(ToHeaderFull).AsString,
              'To');
  CheckEquals('From: Case <sip:case@fried.neurons.org>;tag=1928301774',
              Msg.FirstHeader(FromHeaderFull).AsString,
              'From');
  CheckEquals('CSeq: 314159 INVITE',
              Msg.FirstHeader(CSeqHeader).AsString,
              'CSeq');
  CheckEquals('Contact: sip:wintermute@tessier-ashpool.co.luna',
              Msg.FirstContact.AsString,
              'Contact');
  CheckEquals('Content-Type: text/plain',
              Msg.FirstHeader(ContentTypeHeaderFull).AsString,
              'Content-Type');

  if CheckBody then
    CheckEquals(BasicBody, Msg.Body, 'message-body');
end;

//* TestTIdSipMessage Published methods ****************************************

procedure TestTIdSipMessage.TestAddHeader;
var
  H: TIdSipHeader;
begin
  Self.Msg.ClearHeaders;

  H := TIdSipHeader.Create;
  try
    H.Name := UserAgentHeader;
    H.Value := 'Dog''s breakfast v0.1';

    Self.Msg.AddHeader(H);

    Check(Self.Msg.HasHeader(UserAgentHeader), 'No header added');

    CheckEquals(H.Name,
                Self.Msg.Headers.Items[0].Name,
                'Name not copied');

    CheckEquals(H.Value,
                Self.Msg.Headers.Items[0].Value,
                'Value not copied');
  finally
    H.Free;
  end;

  CheckEquals(UserAgentHeader,
              Self.Msg.Headers.Items[0].Name,
              'And we check that the header was copied & we''re not merely '
            + 'storing a reference');
end;

procedure TestTIdSipMessage.TestAddHeaderName;
begin
  Self.Msg.ClearHeaders;

  CheckNotNull(Self.Msg.AddHeader(UserAgentHeader), 'Nil returned');

  Check(Self.Msg.HasHeader(UserAgentHeader), 'No header added');
end;

procedure TestTIdSipMessage.TestAddHeaders;
var
  Headers: TIdSipHeaders;
begin
  Self.Msg.ClearHeaders;

  Headers := TIdSipHeaders.Create;
  try
    Headers.Add(UserAgentHeader).Value := '0';
    Headers.Add(UserAgentHeader).Value := '1';
    Headers.Add(UserAgentHeader).Value := '2';
    Headers.Add(UserAgentHeader).Value := '3';

    Self.Msg.AddHeaders(Headers);
    Self.Msg.Headers.Equals(Headers);
  finally
    Headers.Free;
  end;
end;

procedure TestTIdSipMessage.TestAssignCopiesBody;
var
  AnotherMsg: TIdSipMessage;
begin
  AnotherMsg := TIdSipTrivialMessage.Create;
  try
    Self.Msg.Body := 'I am a body';

    AnotherMsg.Assign(Self.Msg);
    CheckEquals(Self.Msg.Body,
                AnotherMsg.Body,
                'Body not assigned properly');
  finally
    AnotherMsg.Free;
  end;
end;

procedure TestTIdSipMessage.TestClearHeaders;
begin
  Self.Msg.AddHeader(UserAgentHeader);
  Self.Msg.AddHeader(UserAgentHeader);
  Self.Msg.AddHeader(UserAgentHeader);
  Self.Msg.AddHeader(UserAgentHeader);

  Self.Msg.ClearHeaders;

  CheckEquals(0, Self.Msg.HeaderCount, 'Headers not cleared');
end;

procedure TestTIdSipMessage.TestContactCount;
begin
  Self.Msg.ClearHeaders;
  CheckEquals(0, Self.Msg.ContactCount, 'No headers');

  Self.Msg.AddHeader(ContactHeaderFull);
  CheckEquals(1, Self.Msg.ContactCount, 'Contact');

  Self.Msg.AddHeader(ViaHeaderFull);
  CheckEquals(1, Self.Msg.ContactCount, 'Contact + Via');

  Self.Msg.AddHeader(ContactHeaderFull);
  CheckEquals(2, Self.Msg.ContactCount, '2 Contacts + Via');
end;

procedure TestTIdSipMessage.TestFirstContact;
var
  C: TIdSipHeader;
begin
  Self.Msg.ClearHeaders;

  CheckNotNull(Self.Msg.FirstContact, 'Contact not present');
  CheckEquals(1, Self.Msg.HeaderCount, 'Contact not auto-added');

  C := Self.Msg.FirstHeader(ContactHeaderFull);
  Self.Msg.AddHeader(ContactHeaderFull);

  Check(C = Self.Msg.FirstContact, 'Wrong Contact');
end;

procedure TestTIdSipMessage.TestFirstExpires;
var
  E: TIdSipHeader;
begin
  Self.Msg.ClearHeaders;

  CheckNotNull(Self.Msg.FirstExpires, 'Expires not present');
  CheckEquals(1, Self.Msg.HeaderCount, 'Expires not auto-added');

  E := Self.Msg.FirstHeader(ExpiresHeader);
  Self.Msg.AddHeader(ExpiresHeader);

  Check(E = Self.Msg.FirstExpires, 'Wrong Expires');
end;

procedure TestTIdSipMessage.TestFirstHeader;
var
  H: TIdSipHeader;
begin
  Self.Msg.ClearHeaders;
  H := Self.Msg.AddHeader(UserAgentHeader);
  Check(H = Self.Msg.FirstHeader(UserAgentHeader),
        'Wrong result returned for first User-Agent');

  H := Self.Msg.AddHeader(RouteHeader);
  Check(H = Self.Msg.FirstHeader(RouteHeader),
        'Wrong result returned for first Route');

  H := Self.Msg.AddHeader(RouteHeader);
  Check(H <> Self.Msg.FirstHeader(RouteHeader),
        'Wrong result returned for first Route of two');
end;

procedure TestTIdSipMessage.TestFirstMinExpires;
var
  E: TIdSipHeader;
begin
  Self.Msg.ClearHeaders;

  CheckNotNull(Self.Msg.FirstMinExpires, 'Min-Expires not present');
  CheckEquals(1, Self.Msg.HeaderCount, 'Min-Expires not auto-added');

  E := Self.Msg.FirstHeader(MinExpiresHeader);
  Self.Msg.AddHeader(MinExpiresHeader);

  Check(E = Self.Msg.FirstMinExpires, 'Wrong Min-Expires');
end;

procedure TestTIdSipMessage.TestFirstRequire;
var
  R: TIdSipHeader;
begin
  Self.Msg.ClearHeaders;

  CheckNotNull(Self.Msg.FirstRequire, 'Require not present');
  CheckEquals(1, Self.Msg.HeaderCount, 'Require not auto-added');

  R := Self.Msg.FirstHeader(RequireHeader);
  Self.Msg.AddHeader(RequireHeader);

  Check(R = Self.Msg.FirstRequire, 'Wrong Require');
end;

procedure TestTIdSipMessage.TestHasExpiry;
begin
  Self.Msg.ClearHeaders;
  Check(not Self.Msg.HasExpiry, 'No headers');

  Self.Msg.AddHeader(ExpiresHeader);
  Check(Self.Msg.HasExpiry, 'Expires header');

  Self.Msg.ClearHeaders;
  Self.Msg.AddHeader(ContactHeaderFull).Value := 'sip:hiro@enki.org';
  Check(not Self.Msg.HasExpiry,
        'Contact with no Expires parameter or Expires header');

  Self.Msg.AddHeader(ContactHeaderFull).Value := 'sip:hiro@enki.org;expires=10';
  Check(Self.Msg.HasExpiry,
        'No Expires header and Contact with Expires parameter');

  Self.Msg.AddHeader(ExpiresHeader);
  Check(Self.Msg.HasExpiry,
        'Expires header and Contact with Expires parameter');
end;

procedure TestTIdSipMessage.TestIsMalformedContentLength;
begin
  Self.AddRequiredHeaders(Self.Msg);
  Self.Msg.ContentType := 'text/plain';

  Check(not Self.Msg.IsMalformed,
        'Missing Content-Length; empty body');

  Self.Msg.Body := 'foo';
  Check(Self.Msg.IsMalformed,
        'Content-Length = 0; body = ''foo''');

  Self.Msg.Body := 'foo';
  Self.Msg.ContentLength := 3;
  Check(not Self.Msg.IsMalformed,
        'Content-Length = 3; body = ''foo''');
end;

procedure TestTIdSipMessage.TestIsMalformedMalformedHeader;
const
  // Note the malformed Expires header
  MalformedMessage = 'SIP/2.0 200 OK'#13#10
                   + 'Expires: a'#13#10
                   + 'Via:     SIP/2.0/UDP c.bell-tel.com;branch=z9hG4bKkdjuw'#13#10
                   + 'Max-Forwards:     70'#13#10
                   + 'From:    A. Bell <sip:a.g.bell@bell-tel.com>;tag=qweoiqpe'#13#10
                   + 'To:      T. Watson <sip:t.watson@ieee.org>'#13#10
                   + 'Call-ID: 31417@c.bell-tel.com'#13#10
                   + 'CSeq:    1 INVITE'#13#10
                   + #13#10;
var
  ExpectedReason: String;
  Res:            TIdSipResponse;
begin
  ExpectedReason := Format(MalformedToken, [ExpiresHeader, 'a']);

  Res := TIdSipMessage.ReadResponseFrom(MalformedMessage);
  try
    Check(Res.IsMalformed,
          'Response not marked as invalid');

    CheckEquals(ExpectedReason,
                Res.ParseFailReason,
                'Unexpected parse fail reason');

    Check(Res.HasHeader(CSeqHeader),
          'The bad syntax bailed us out of parsing the rest of the message');
  finally
    Res.Free;
  end;
end;

procedure TestTIdSipMessage.TestIsMalformedMissingContentType;
begin
  Self.AddRequiredHeaders(Self.Msg);
  Self.Msg.Body := 'foo';
  Self.Msg.ContentLength := 3;
  Check(Self.Msg.IsMalformed,
        'Length(Body) > 0 but no Content-Type');

  Self.Msg.ContentType := 'text/plain';
  Check(not Self.Msg.IsMalformed,
        'Content-Type present');
end;

procedure TestTIdSipMessage.TestIsMalformedMissingCallID;
begin
  Self.AddRequiredHeaders(Self.Msg);
  Self.Msg.RemoveAllHeadersNamed(CallIDHeaderFull);

  Check(Self.Msg.IsMalformed, 'Missing Call-ID header');
end;

procedure TestTIdSipMessage.TestIsMalformedMissingCseq;
begin
  Self.AddRequiredHeaders(Self.Msg);
  Self.Msg.RemoveAllHeadersNamed(CSeqHeader);

  Check(Self.Msg.IsMalformed, 'Missing CSeq header');
end;

procedure TestTIdSipMessage.TestIsMalformedMissingFrom;
begin
  Self.AddRequiredHeaders(Self.Msg);
  Self.Msg.RemoveAllHeadersNamed(FromHeaderFull);

  Check(Self.Msg.IsMalformed, 'Missing From header');
end;

procedure TestTIdSipMessage.TestIsMalformedMissingTo;
begin
  Self.AddRequiredHeaders(Self.Msg);
  Self.Msg.RemoveAllHeadersNamed(ToHeaderFull);

  Check(Self.Msg.IsMalformed, 'Missing To header');
end;

procedure TestTIdSipMessage.TestIsMalformedMissingVia;
begin
  Self.AddRequiredHeaders(Self.Msg);
  Self.Msg.RemoveAllHeadersNamed(ViaHeaderFull);

  Check(Self.Msg.IsMalformed, 'Missing Via header');
end;

procedure TestTIdSipMessage.TestHeaderCount;
begin
  Self.Msg.ClearHeaders;
  Self.Msg.AddHeader(UserAgentHeader);

  CheckEquals(1, Self.Msg.HeaderCount, 'HeaderCount not correct');
end;

procedure TestTIdSipMessage.TestLastHop;
begin
  Self.Msg.ClearHeaders;
  Check(Self.Msg.LastHop = Self.Msg.FirstHeader(ViaHeaderFull), 'Unexpected return for empty path');

  Self.Msg.AddHeader(ViaHeaderFull);
  Check(Self.Msg.LastHop = Self.Msg.Path.LastHop, 'Unexpected return');
end;

procedure TestTIdSipMessage.TestQuickestExpiry;
begin
  Self.Msg.ClearHeaders;
  CheckEquals(0, Self.Msg.QuickestExpiry, 'No headers');

  Self.Msg.AddHeader(ExpiresHeader).Value := '10';
  CheckEquals(10, Self.Msg.QuickestExpiry, 'An Expiry header');

  Self.Msg.AddHeader(ExpiresHeader).Value := '9';
  CheckEquals(9, Self.Msg.QuickestExpiry, 'Two Expiry headers');

  Self.Msg.AddHeader(ContactHeaderFull).Value := 'sip:hiro@enki.org';
  CheckEquals(9, Self.Msg.QuickestExpiry, 'Two Expiry headers + Contact');

  Self.Msg.AddHeader(ContactHeaderFull).Value := 'sip:hiro@enki.org;expires=10';
  CheckEquals(9, Self.Msg.QuickestExpiry, 'Two Expiry headers + two Contacts');

  Self.Msg.AddHeader(ContactHeaderFull).Value := 'sip:case@fried.neurons.org;expires=8';
  CheckEquals(8, Self.Msg.QuickestExpiry, 'Two Expiry headers + three Contacts');
end;

procedure TestTIdSipMessage.TestQuickestExpiryNoExpires;
begin
  Self.Msg.AddHeader(ContactHeaderFull).Value := 'sip:hiro@enki.org;expires=10';
  CheckEquals(10, Self.Msg.QuickestExpiry, 'One Contact');

  Self.Msg.AddHeader(ContactHeaderFull).Value := 'sip:case@fried.neurons.org;expires=8';
  CheckEquals(8, Self.Msg.QuickestExpiry, 'Two Contacts');

  Self.Msg.AddHeader(ContactHeaderFull).Value := 'sip:case@fried.neurons.org;expires=22';
  CheckEquals(8, Self.Msg.QuickestExpiry, 'Three Contacts');
end;

procedure TestTIdSipMessage.TestReadBody;
var
  Len:       Integer;
  Msg:       String;
  Remainder: String;
  S:         String;
  Str:       TStringStream;
begin
  Self.Msg.ContentLength := 8;

  Msg := 'Negotium perambuians in tenebris';
  Str := TStringStream.Create(Msg);
  try
    Self.Msg.ReadBody(Str);
    CheckEquals(System.Copy(Msg, 1, 8), Self.Msg.Body, 'Body');

    Remainder := Msg;
    Delete(Remainder, 1, 8);

    Len := Length(Remainder);
    SetLength(S, Len);
    Str.Read(S[1], Len);
    CheckEquals(Remainder, S, 'Unread bits of the stream');
  finally
    Str.Free;
  end;
end;

procedure TestTIdSipMessage.TestReadBodyWithZeroContentLength;
var
  Len: Integer;
  S:   String;
  Str: TStringStream;
  Msg: String;
begin
  Self.Msg.ContentLength := 0;
  Msg := 'Negotium perambuians in tenebris';

  Str := TStringStream.Create(Msg);
  try
    Self.Msg.ReadBody(Str);
    CheckEquals('', Self.Msg.Body, 'Body');

    Len := Length(Msg);
    SetLength(S, Len);
    Str.Read(S[1], Len);
    CheckEquals(Msg, S, 'Unread bits of the stream');
  finally
    Str.Free;
  end;
end;

procedure TestTIdSipMessage.TestRemoveHeader;
begin
  Self.Msg.ClearHeaders;

  Self.Msg.AddHeader(ContentTypeHeaderFull);
  Check(Self.Msg.HasHeader(ContentTypeHeaderFull),
        'Content-Type wasn''t added');

  Self.Msg.RemoveHeader(Self.Msg.FirstHeader(ContentTypeHeaderFull));
  Check(not Self.Msg.HasHeader(ContentTypeHeaderFull),
        'Content-Type wasn''t removeed');
end;

procedure TestTIdSipMessage.TestRemoveHeaders;
begin
  Self.Msg.ClearHeaders;

  Self.Msg.AddHeader(ContentTypeHeaderFull);
  Self.Msg.AddHeader(ContentTypeHeaderFull);
  Self.Msg.AddHeader(ContentTypeHeaderFull);

  Self.Msg.RemoveAllHeadersNamed(ContentTypeHeaderFull);

  Check(not Self.Msg.HasHeader(ContentTypeHeaderFull),
        'Content-Type wasn''t removeed');
end;

procedure TestTIdSipMessage.TestSetCallID;
begin
  Self.Msg.CallID := '999';

  Self.Msg.CallID := '42';
  CheckEquals('42', Self.Msg.CallID, 'Call-ID not set');
end;

procedure TestTIdSipMessage.TestSetContacts;
var
  H: TIdSipHeaders;
  C: TIdSipContacts;
begin
  Self.Msg.AddHeader(ContactHeaderFull).Value := 'sip:case@fried.neurons.org';

  H := TIdSipHeaders.Create;
  try
    H.Add(ContactHeaderFull).Value := 'sips:wintermute@tessier-ashpool.co.luna';
    H.Add(ContactHeaderFull).Value := 'Wintermute <sip:wintermute@tessier-ashpool.co.luna>';
    C := TIdSipContacts.Create(H);
    try
      Self.Msg.Contacts := C;

      Check(Self.Msg.Contacts.Equals(C), 'Path not correctly set');
    finally
      C.Free;
    end;
  finally
    H.Free;
  end;
end;

procedure TestTIdSipMessage.TestSetContentLanguage;
begin
  Self.Msg.ContentLanguage := 'es';

  Self.Msg.ContentLanguage := 'en';
  CheckEquals('en', Self.Msg.ContentLanguage, 'Content-Language not set');
end;

procedure TestTIdSipMessage.TestSetContentLength;
begin
  Self.Msg.ContentLength := 999;

  Self.Msg.ContentLength := 42;
  CheckEquals(42, Self.Msg.ContentLength, 'Content-Length not set');
end;

procedure TestTIdSipMessage.TestSetContentType;
begin
  Self.Msg.ContentType := 'text/plain';

  Self.Msg.ContentType := 'text/t140';
  CheckEquals('text/t140', Self.Msg.ContentType, 'Content-Type not set');
end;

procedure TestTIdSipMessage.TestSetCSeq;
var
  C: TIdSipCSeqHeader;
begin
  C := TIdSipCSeqHeader.Create;
  try
    C.Value := '314159 INVITE';

    Self.Msg.CSeq := C;

    Check(Self.Msg.CSeq.Equals(C), 'CSeq not set');
  finally
    C.Free;
  end;
end;

procedure TestTIdSipMessage.TestSetFrom;
var
  From: TIdSipFromHeader;
begin
  Self.Msg.From.Value := 'Wintermute <sip:wintermute@tessier-ashpool.co.luna>';

  From := TIdSipFromHeader.Create;
  try
    From.Value := 'Case <sip:case@fried.neurons.org>';

    Self.Msg.From := From;

    CheckEquals(From.Value, Self.Msg.From.Value, 'From value not set');
  finally
    From.Free;
  end;
end;

procedure TestTIdSipMessage.TestSetPath;
var
  H: TIdSipHeaders;
  P: TIdSipViaPath;
begin
  Self.Msg.AddHeader(ViaHeaderFull).Value := 'SIP/2.0/TCP gw1.leo-ix.org;branch=z9hG4bK776asdhds';

  H := TIdSipHeaders.Create;
  try
    H.Add(ViaHeaderFull).Value := 'SIP/2.0/TCP gw2.leo-ix.org;branch=z9hG4bK776asdhds';
    H.Add(ViaHeaderFull).Value := 'SIP/2.0/TCP gw3.leo-ix.org;branch=z9hG4bK776asdhds';
    P := TIdSipViaPath.Create(H);
    try
      Self.Msg.Path := P;

      Check(Self.Msg.Path.Equals(P), 'Path not correctly set');
    finally
      P.Free;
    end;
  finally
    H.Free;
  end;
end;

procedure TestTIdSipMessage.TestSetRecordRoute;
var
  H: TIdSipHeaders;
  P: TIdSipRecordRoutePath;
begin
  Self.Msg.AddHeader(RecordRouteHeader).Value := '<sip:gw1.leo-ix.org>';

  H := TIdSipHeaders.Create;
  try
    H.Add(RecordRouteHeader).Value := '<sip:gw2.leo-ix.org>';
    H.Add(RecordRouteHeader).Value := '<sip:gw3.leo-ix.org;lr>';
    P := TIdSipRecordRoutePath.Create(H);
    try
      Self.Msg.RecordRoute := P;

      Check(Self.Msg.RecordRoute.Equals(P), 'Path not correctly set');
    finally
      P.Free;
    end;
  finally
    H.Free;
  end;
end;

procedure TestTIdSipMessage.TestSetSipVersion;
begin
  Self.Msg.SIPVersion := 'SIP/2.0';

  Self.Msg.SIPVersion := 'SIP/7.7';
  CheckEquals('SIP/7.7', Self.Msg.SipVersion, 'SipVersion not set');
end;

procedure TestTIdSipMessage.TestSetTo;
var
  ToHeader: TIdSipToHeader;
begin
  Self.Msg.ToHeader.Value := 'Wintermute <sip:wintermute@tessier-ashpool.co.luna>';

  ToHeader := TIdSipToHeader.Create;
  try
    ToHeader.Value := 'Case <sip:case@fried.neurons.org>';

    Self.Msg.ToHeader := ToHeader;

    CheckEquals(ToHeader.Value, Self.Msg.ToHeader.Value, 'To value not set');
  finally
    ToHeader.Free;
  end;
end;

procedure TestTIdSipMessage.TestWillEstablishDialog;
var
  I, J:    Integer;
  Request: TIdSipRequest;
  Response: TIdSipResponse;
begin
  Request := TIdSipRequest.Create;
  try
    Response := TIdSipResponse.Create;
    try
      for I := Low(AllMethods) to High(AllMethods) do
        for J := Low(AllResponses) to High(AllResponses) do begin
          Request.Method := AllMethods[I];
          Response.StatusCode := AllResponses[J];

          Check((Request.IsInvite and Response.IsOK)
              = TIdSipMessage.WillEstablishDialog(Request, Response),
                AllMethods[I] + ' + ' + Response.StatusText);
        end;
    finally
      Response.Free;
    end;
  finally
    Request.Free;
  end;
end;

//******************************************************************************
//* TestTIdSipRequest                                                          *
//******************************************************************************
//* TestTIdSipRequest Public methods *******************************************

procedure TestTIdSipRequest.SetUp;
begin
  inherited SetUp;

  Self.Msg.SIPVersion := SIPVersion;
  (Self.Msg as TIdSipRequest).Method := 'foo';
  (Self.Msg as TIdSipRequest).RequestUri.Uri := 'sip:foo';

  Self.Request  := TIdSipTestResources.CreateBasicRequest;
  Self.Response := TIdSipTestResources.CreateBasicResponse;
end;

procedure TestTIdSipRequest.TearDown;
begin
  Self.Response.Free;
  Self.Request.Free;

  inherited TearDown;
end;

//* TestTIdSipRequest Protected methods ****************************************

function TestTIdSipRequest.MessageType: TIdSipMessageClass;
begin
  Result := TIdSipRequest;
end;

//* TestTIdSipRequest Private methods ******************************************

procedure TestTIdSipRequest.CheckBasicRequest(Msg: TIdSipMessage;
                                             CheckBody: Boolean = true);
begin
  CheckEquals(TIdSipRequest.Classname, Msg.ClassName, 'Class type');

  CheckEquals('INVITE',
              (Msg as TIdSipRequest).Method,
              'Method');
  CheckEquals('sip:wintermute@tessier-ashpool.co.luna',
              (Msg as TIdSipRequest).RequestUri.URI,
              'Request-URI');
  CheckEquals(70, (Msg as TIdSipRequest).MaxForwards, 'MaxForwards');
  CheckEquals(9,  Msg.HeaderCount, 'Header count');

  Self.CheckBasicMessage(Msg, CheckBody);
end;

//* TestTIdSipRequest Published methods ****************************************

procedure TestTIdSipRequest.TestAckForEstablishingDialog;
var
  Ack: TIdSipRequest;
begin
  Self.Request.Method      := MethodInvite;
  Self.Response.StatusCode := SIPOK;

  Ack := Self.Request.AckFor(Self.Response);
  try
    Check(Ack.IsAck, 'Method');
    CheckEquals(Self.Request.CallID, Ack.CallID, 'Call-ID');
    CheckEquals(Self.Request.From.Address.AsString,
                Ack.From.Address.AsString,
                'From address');
    CheckEquals(Self.Request.From.Tag,
                Ack.From.Tag,
                'From tag');
    CheckEquals(Self.Request.RequestUri.Uri,
                Ack.RequestUri.Uri,
                'Request-URI');
    CheckEquals(Self.Request.ToHeader.Address.AsString,
                Ack.ToHeader.Address.AsString,
                'To address');
    CheckEquals(Self.Request.ToHeader.Tag,
                Ack.ToHeader.Tag,
                'To tag');
    CheckEquals(1, Ack.Path.Count, 'Via path hop count');
    CheckEquals(Self.Response.LastHop.Value,
                Ack.LastHop.Value,
                'Via last hop');
    CheckNotEquals(Self.Response.LastHop.Branch,
                Ack.LastHop.Branch,
                'Via last hop branch');
    CheckEquals(Self.Request.Cseq.SequenceNo,
                Ack.Cseq.SequenceNo,
                'CSeq sequence no');
    CheckEquals(MethodAck,
                Ack.Cseq.Method,
                'CSeq method');
  finally
    Ack.Free;
  end;
end;

procedure TestTIdSipRequest.TestAckFor;
var
  Ack: TIdSipRequest;
begin
  Self.Request.Method      := MethodInvite;
  Self.Response.StatusCode := SIPNotFound;

  Ack := Self.Request.AckFor(Self.Response);
  try
    Check(Ack.IsAck, 'Method');
    CheckEquals(Self.Request.CallID, Ack.CallID, 'Call-ID');
    CheckEquals(Self.Request.From.AsString,
                Ack.From.AsString,
                'From');
    CheckEquals(Self.Request.RequestUri.Uri,
                Ack.RequestUri.Uri,
                'Request-URI');
    CheckEquals(Self.Response.ToHeader.AsString,
                Ack.ToHeader.AsString,
                'To');
    CheckEquals(1, Ack.Path.Count, 'Via path hop count');
    CheckEquals(Self.Response.LastHop.Value,
                Ack.LastHop.Value,
                'Via last hop');
    CheckEquals(Self.Response.LastHop.Branch,
                Ack.LastHop.Branch,
                'Via last hop branch');
    CheckEquals(Self.Request.Cseq.SequenceNo,
                Ack.Cseq.SequenceNo,
                'CSeq sequence no');
    CheckEquals(MethodAck,
                Ack.Cseq.Method,
                'CSeq method');
  finally
    Ack.Free;
  end;
end;

procedure TestTIdSipRequest.TestAckForWithAuthentication;
var
  Ack: TIdSipRequest;
begin
  Self.Request.Method := MethodInvite;
  Self.Request.AddHeader(AuthorizationHeader).Value := 'foo';
  Self.Request.AddHeader(ProxyAuthorizationHeader).Value := 'foo';

  Ack := Self.Request.AckFor(Self.Response);
  try
    Check(Ack.HasHeader(AuthorizationHeader),
          'No Authorization header');
    Check(Ack.FirstHeader(AuthorizationHeader).Equals(Self.Request.FirstHeader(AuthorizationHeader)),
          'Authorization');

    Check(Ack.HasHeader(ProxyAuthorizationHeader),
          'No Proxy-Authorization header');
    Check(Ack.FirstHeader(ProxyAuthorizationHeader).Equals(Self.Request.FirstHeader(ProxyAuthorizationHeader)),
          'Proxy-Authorization');
  finally
    Ack.Free;
  end;
end;

procedure TestTIdSipRequest.TestAckForWithRoute;
var
  Ack: TIdSipRequest;
begin
  Self.Request.Method      := MethodInvite;
  Self.Response.StatusCode := SIPRequestTimeout;

  Self.Request.AddHeader(RouteHeader).Value := '<sip:gw1.tessier-ashpool.co.luna;lr>';
  Self.Request.AddHeader(RouteHeader).Value := '<sip:gw2.tessier-ashpool.co.luna>';

  Ack := Self.Request.AckFor(Self.Response);
  try
    Check(Self.Request.Route.Equals(Ack.Route),
          'Route path');
  finally
    Ack.Free;
  end;
end;

procedure TestTIdSipRequest.TestAddressOfRecord;
begin
  CheckEquals(Self.Request.ToHeader.AsAddressOfRecord,
              Self.Request.AddressOfRecord,
              'AddressOfRecord');

  Self.Request.RequestUri.Uri := 'sip:proxy.tessier-ashpool.co.luna';
  CheckEquals(Self.Request.ToHeader.AsAddressOfRecord,
              Self.Request.AddressOfRecord,
              'AddressOfRecord');
end;

procedure TestTIdSipRequest.TestAssign;
var
  R: TIdSipRequest;
begin
  R := TIdSipRequest.Create;
  try
    R.SIPVersion := 'SIP/1.5';
    R.Method := 'NewMethod';
    R.RequestUri.URI := 'sip:wintermute@tessier-ashpool.co.luna';
    R.AddHeader(ViaHeaderFull).Value := 'SIP/2.0/TCP gw1.leo-ix.org;branch=z9hG4bK776asdhds';
    R.ContentLength := 5;
    R.Body := 'hello';

    Self.Request.Assign(R);
    CheckEquals(R.SIPVersion,    Self.Request.SipVersion,    'SIP-Version');
    CheckEquals(R.Method,        Self.Request.Method,        'Method');
    CheckEquals(R.RequestUri,    Self.Request.RequestUri,    'Request-URI');

    Check(R.Headers.Equals(Self.Request.Headers),
          'Headers not assigned properly');
  finally
    R.Free;
  end;
end;

procedure TestTIdSipRequest.TestAssignBad;
var
  P: TPersistent;
begin
  P := TPersistent.Create;
  try
    try
      Self.Request.Assign(P);
      Fail('Failed to bail out assigning a TPersistent to a TIdSipRequest');
    except
      on EConvertError do;
    end;
  finally
    P.Free;
  end;
end;

procedure TestTIdSipRequest.TestAsString;
var
  Expected: TStringList;
  Received: TStringList;
  Req:      TIdSipRequest;
begin
  Expected := TStringList.Create;
  try
    Expected.Text := BasicRequest;
    Expected.Sort;

    Received := TStringList.Create;
    try
      Received.Text := Self.Request.AsString;

      Req := TIdSipMessage.ReadRequestFrom(Self.Request.AsString);
      try
        Check(not Req.IsMalformed, 'Sanity check AsString');
      finally
        Req.Free;
      end;

      Received.Sort;
      CheckEquals(Expected, Received, 'AsString');
    finally
      Received.Free;
    end;
  finally
    Expected.Free;
  end;
end;

procedure TestTIdSipRequest.TestAsStringNoMaxForwardsSet;
begin
  Check(Pos(MaxForwardsHeader, Self.Request.AsString) > 0,
        'No Max-Forwards header');
end;

procedure TestTIdSipRequest.TestCopy;
var
  Cancel: TIdSipRequest;
  Copy:   TIdSipMessage;
begin
  Cancel := Self.Request.CreateCancel;
  try
    Copy := Cancel.Copy;
    try
      Check(Copy.Equals(Cancel), 'Copy = Cancel');
      Check(Cancel.Equals(Copy), 'Cancel = Copy');
    finally
      Copy.Free;
    end;
  finally
    Cancel.Free;
  end;
end;

procedure TestTIdSipRequest.TestCreateCancel;
var
  Cancel: TIdSipRequest;
begin
  Cancel := Self.Request.CreateCancel;
  try
    CheckEquals(MethodCancel, Cancel.Method, 'Unexpected method');
    CheckEquals(MethodCancel,
                Cancel.CSeq.Method,
                'CSeq method');
    Check(Self.Request.RequestUri.Equals(Cancel.RequestUri),
          'Request-URI');
    CheckEquals(Self.Request.CallID,
                Cancel.CallID,
                'Call-ID header');
    Check(Self.Request.ToHeader.Equals(Cancel.ToHeader),
          'To header');
    CheckEquals(Self.Request.CSeq.SequenceNo,
                Cancel.CSeq.SequenceNo,
                'CSeq numerical portion');
    Check(Self.Request.From.Equals(Cancel.From),
          'From header');
    CheckEquals(1,
                Cancel.Path.Length,
                'Via headers');
  finally
    Cancel.Free;
  end;
end;

procedure TestTIdSipRequest.TestCreateCancelANonInviteRequest;
begin
  Self.Request.Method := MethodOptions;
  try
    Self.Request.CreateCancel;
    Fail('Failed to bail out of creating a CANCEL for a non-INVITE request');
  except
    on EAssertionFailed do;
  end;
end;

procedure TestTIdSipRequest.TestCreateCancelWithProxyRequire;
var
  Cancel: TIdSipRequest;
begin
  Self.Request.AddHeader(ProxyRequireHeader).Value := 'foofoo';

  Cancel := Self.Request.CreateCancel;
  try
    Check(not Cancel.HasHeader(ProxyRequireHeader),
          'Proxy-Require headers copied');
  finally
    Cancel.Free;
  end;
end;

procedure TestTIdSipRequest.TestCreateCancelWithRequire;
var
  Cancel: TIdSipRequest;
begin
  Self.Request.AddHeader(RequireHeader).Value := 'foofoo, barbar';

  Cancel := Self.Request.CreateCancel;
  try
    Check(not Cancel.HasHeader(RequireHeader),
          'Require headers copied');
  finally
    Cancel.Free;
  end;
end;

procedure TestTIdSipRequest.TestCreateCancelWithRoute;
var
  Cancel: TIdSipRequest;
begin
  Self.Request.AddHeader(RouteHeader).Value := '<sip:127.0.0.1>';
  Self.Request.AddHeader(RouteHeader).Value := '<sip:127.0.0.2>';

  Cancel := Self.Request.CreateCancel;
  try
    Check(Self.Request.Route.Equals(Cancel.Route),
          'Route headers not copied');
  finally
    Cancel.Free;
  end;
end;

procedure TestTIdSipRequest.TestFirstAuthorization;
var
  A: TIdSipHeader;
begin
  Self.Request.ClearHeaders;

  CheckNotNull(Self.Request.FirstAuthorization, 'Authorization not present');
  CheckEquals(1, Self.Request.HeaderCount, 'Authorization not auto-added');

  A := Self.Request.FirstHeader(AuthorizationHeader);
  Self.Request.AddHeader(AuthorizationHeader);

  Check(A = Self.Request.FirstAuthorization, 'Wrong Authorization');
end;

procedure TestTIdSipRequest.TestFirstProxyAuthorization;
var
  A: TIdSipHeader;
begin
  Self.Request.ClearHeaders;

  CheckNotNull(Self.Request.FirstProxyAuthorization, 'Proxy-Authorization not present');
  CheckEquals(1, Self.Request.HeaderCount, 'Proxy-Authorization not auto-added');

  A := Self.Request.FirstHeader(ProxyAuthorizationHeader);
  Self.Request.AddHeader(AuthorizationHeader);

  Check(A = Self.Request.FirstProxyAuthorization, 'Wrong Proxy-Authorization');
end;

procedure TestTIdSipRequest.TestFirstProxyRequire;
var
  P: TIdSipHeader;
begin
  Self.Request.ClearHeaders;

  CheckNotNull(Self.Request.FirstProxyRequire, 'Proxy-Require not present');
  CheckEquals(1, Self.Request.HeaderCount, 'Proxy-Require not auto-added');

  P := Self.Request.FirstHeader(ProxyRequireHeader);
  Self.Request.AddHeader(ProxyRequireHeader);

  Check(P = Self.Request.FirstProxyRequire, 'Wrong Proxy-Require');
end;

procedure TestTIdSipRequest.TestHasSipsUri;
begin
  Self.Request.RequestUri.URI := 'tel://999';
  Check(not Self.Request.HasSipsUri, 'tel URI');

  Self.Request.RequestUri.URI := 'sip:wintermute@tessier-ashpool.co.luna';
  Check(not Self.Request.HasSipsUri, 'sip URI');

  Self.Request.RequestUri.URI := 'sips:wintermute@tessier-ashpool.co.luna';
  Check(Self.Request.HasSipsUri, 'sips URI');
end;

procedure TestTIdSipRequest.TestIsMalformedCSeqMethod;
begin
  Self.Request.Method := MethodInvite;
  Self.Request.CSeq.Method := Self.Request.Method;
  Check(not Self.Request.IsMalformed,
       'CSeq method matches request method');

  Self.Request.CSeq.Method := Self.Request.CSeq.Method + '1';;
  Check(Self.Request.IsMalformed,
       'CSeq method matches request method');
end;

procedure TestTIdSipRequest.TestIsMalformedSipVersion;
const
  MalformedMessage = 'INVITE sip:wintermute@tessier-ashpool.co.luna SIP/;2.0'#13#10
                   + 'Via:     SIP/2.0/UDP c.bell-tel.com;branch=z9hG4bKkdjuw'#13#10
                   + 'Max-Forwards:     70'#13#10
                   + 'From:    A. Bell <sip:a.g.bell@bell-tel.com>;tag=qweoiqpe'#13#10
                   + 'To:      T. Watson <sip:t.watson@ieee.org>'#13#10
                   + 'Call-ID: 31417@c.bell-tel.com'#13#10
                   + 'CSeq:    1 INVITE'#13#10
                   + #13#10;
var
  ExpectedReason: String;
  Msg:            TIdSipMessage;
begin
  ExpectedReason := Format(InvalidSipVersion, ['SIP/;2.0']);

  Msg := TIdSipMessage.ReadMessageFrom(MalformedMessage);
  try
    Check(Msg.IsMalformed,
          'Msg has invalid SIP-Version, but not branded as such');
    CheckEquals(ExpectedReason,
                Msg.ParseFailReason,
                'Unexpected parse error reason');
    CheckEquals(Copy(MalformedMessage, 1, 255),
                Copy(Msg.RawMessage, 1, 255),
                'Unexpected raw message');
  finally
    Msg.Free;
  end;
end;

procedure TestTIdSipRequest.TestIsMalformedMethod;
begin
  Self.Request.ClearHeaders;
  Self.AddRequiredHeaders(Self.Request);
  Self.Request.Method := 'Bad"Method';

  Check(Self.Msg.IsMalformed, 'Bad Method');
end;

procedure TestTIdSipRequest.TestIsMalformedMissingVia;
begin
  Self.AddRequiredHeaders(Self.Msg);
  Self.Msg.RemoveAllHeadersNamed(ViaHeaderFull);

  Check(Self.Msg.IsMalformed, 'Missing Via header');
end;

procedure TestTIdSipRequest.TestIsAck;
begin
  Self.Request.Method := MethodAck;
  Check(Self.Request.IsAck, MethodAck);

  Self.Request.Method := MethodBye;
  Check(not Self.Request.IsAck, MethodBye);

  Self.Request.Method := MethodCancel;
  Check(not Self.Request.IsAck, MethodCancel);

  Self.Request.Method := MethodInvite;
  Check(not Self.Request.IsAck, MethodInvite);

  Self.Request.Method := MethodOptions;
  Check(not Self.Request.IsAck, MethodOptions);

  Self.Request.Method := MethodRegister;
  Check(not Self.Request.IsAck, MethodRegister);

  Self.Request.Method := 'XXX';
  Check(not Self.Request.IsAck, 'XXX');
end;

procedure TestTIdSipRequest.TestIsBye;
begin
  Self.Request.Method := MethodAck;
  Check(not Self.Request.IsBye, MethodAck);

  Self.Request.Method := MethodBye;
  Check(Self.Request.IsBye, MethodBye);

  Self.Request.Method := MethodCancel;
  Check(not Self.Request.IsBye, MethodCancel);

  Self.Request.Method := MethodInvite;
  Check(not Self.Request.IsBye, MethodInvite);

  Self.Request.Method := MethodOptions;
  Check(not Self.Request.IsBye, MethodOptions);

  Self.Request.Method := MethodRegister;
  Check(not Self.Request.IsBye, MethodRegister);

  Self.Request.Method := 'XXX';
  Check(not Self.Request.IsBye, 'XXX');
end;

procedure TestTIdSipRequest.TestIsCancel;
begin
  Self.Request.Method := MethodAck;
  Check(not Self.Request.IsCancel, MethodAck);

  Self.Request.Method := MethodBye;
  Check(not Self.Request.IsCancel, MethodBye);

  Self.Request.Method := MethodCancel;
  Check(Self.Request.IsCancel, MethodCancel);

  Self.Request.Method := MethodInvite;
  Check(not Self.Request.IsCancel, MethodInvite);

  Self.Request.Method := MethodOptions;
  Check(not Self.Request.IsCancel, MethodOptions);

  Self.Request.Method := MethodRegister;
  Check(not Self.Request.IsCancel, MethodRegister);

  Self.Request.Method := 'XXX';
  Check(not Self.Request.IsCancel, 'XXX');
end;

procedure TestTIdSipRequest.TestEqualsComplexMessages;
var
  R: TIdSipRequest;
begin
  R := TIdSipTestResources.CreateBasicRequest;
  try
    Check(Self.Request.Equals(R), 'Request = R');
    Check(R.Equals(Self.Request), 'R = Request');
  finally
    R.Free
  end;
end;

procedure TestTIdSipRequest.TestEqualsDifferentHeaders;
var
  R1, R2: TIdSipRequest;
begin
  R1 := TIdSipRequest.Create;
  try
    R2 := TIdSipRequest.Create;
    try
      R1.AddHeader(ViaHeaderFull);

      Check(not R1.Equals(R2), 'R1 <> R2');
      Check(not R2.Equals(R1), 'R2 <> R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipRequest.TestEqualsDifferentMethod;
var
  R1, R2: TIdSipRequest;
begin
  R1 := TIdSipRequest.Create;
  try
    R2 := TIdSipRequest.Create;
    try
      R1.Method := MethodInvite;
      R2.Method := MethodOptions;

      Check(not R1.Equals(R2), 'R1 <> R2');
      Check(not R2.Equals(R1), 'R2 <> R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipRequest.TestEqualsDifferentRequestUri;
var
  R1, R2: TIdSipRequest;
begin
  R1 := TIdSipRequest.Create;
  try
    R2 := TIdSipRequest.Create;
    try
      R1.RequestUri.URI := 'sip:wintermute@tessier-ashpool.co.luna';
      R1.RequestUri.URI := 'sip:case@fried.neurons.org';

      Check(not R1.Equals(R2), 'R1 <> R2');
      Check(not R2.Equals(R1), 'R2 <> R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipRequest.TestEqualsDifferentSipVersion;
var
  R1, R2: TIdSipRequest;
begin
  R1 := TIdSipRequest.Create;
  try
    R2 := TIdSipRequest.Create;
    try
      R1.SIPVersion := 'SIP/2.0';
      R2.SIPVersion := 'SIP/2.1';

      Check(not R1.Equals(R2), 'R1 <> R2');
      Check(not R2.Equals(R1), 'R2 <> R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipRequest.TestEqualsFromAssign;
var
  Req: TIdSipRequest;
begin
  Req := TIdSipRequest.Create;
  try
    Req.Assign(Self.Request);

    Check(Req.Equals(Self.Request), 'Assigned = Original');
    Check(Self.Request.Equals(Req), 'Original = Assigned');
  finally
    Req.Free;
  end;
end;

procedure TestTIdSipRequest.TestEqualsResponse;
var
  Req: TIdSipRequest;
  Res: TIdSipResponse;
begin
  Req := TIdSipRequest.Create;
  try
    Res := TIdSipResponse.Create;
    try
      Check(not Req.Equals(Res), 'Req <> Res');
    finally
      Res.Free;
    end;
  finally
    Req.Free;
  end;
end;

procedure TestTIdSipRequest.TestEqualsTrivial;
var
  R1, R2: TIdSipRequest;
begin
  R1 := TIdSipRequest.Create;
  try
    R2 := TIdSipRequest.Create;
    try
      Check(R1.Equals(R2), 'R1 = R2');
      Check(R2.Equals(R1), 'R2 = R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipRequest.TestHasAuthorization;
begin
  Check(not Self.Request.HasHeader(ProxyAuthorizationHeader),
        'Sanity check');

  Check(not Self.Request.HasProxyAuthorization,
        'New request');


  Self.Request.AddHeader(ProxyAuthorizationHeader);
  Check(Self.Request.HasProxyAuthorization,
        'Lies! There is too a Proxy-Authorization header!');
end;

procedure TestTIdSipRequest.TestHasProxyAuthorization;
begin
  Check(not Self.Request.HasHeader(AuthorizationHeader),
        'Sanity check');

  Check(not Self.Request.HasAuthorization,
        'New request');


  Self.Request.AddHeader(AuthorizationHeader);
  Check(Self.Request.HasAuthorization,
        'Lies! There is too a Authorization header!');
end;

procedure TestTIdSipRequest.TestIsInvite;
begin
  Self.Request.Method := MethodAck;
  Check(not Self.Request.IsInvite, MethodAck);

  Self.Request.Method := MethodBye;
  Check(not Self.Request.IsInvite, MethodBye);

  Self.Request.Method := MethodCancel;
  Check(not Self.Request.IsInvite, MethodCancel);

  Self.Request.Method := MethodInvite;
  Check(Self.Request.IsInvite, MethodInvite);

  Self.Request.Method := MethodOptions;
  Check(not Self.Request.IsInvite, MethodOptions);

  Self.Request.Method := MethodRegister;
  Check(not Self.Request.IsInvite, MethodRegister);

  Self.Request.Method := 'XXX';
  Check(not Self.Request.IsInvite, 'XXX');
end;

procedure TestTIdSipRequest.TestIsOptions;
begin
  Self.Request.Method := MethodAck;
  Check(not Self.Request.IsOptions, MethodAck);

  Self.Request.Method := MethodBye;
  Check(not Self.Request.IsOptions, MethodBye);

  Self.Request.Method := MethodCancel;
  Check(not Self.Request.IsOptions, MethodCancel);

  Self.Request.Method := MethodInvite;
  Check(not Self.Request.IsOptions, MethodInvite);

  Self.Request.Method := MethodOptions;
  Check(Self.Request.IsOptions, MethodOptions);

  Self.Request.Method := MethodRegister;
  Check(not Self.Request.IsOptions, MethodRegister);

  Self.Request.Method := 'XXX';
  Check(not Self.Request.IsOptions, 'XXX');
end;

procedure TestTIdSipRequest.TestIsRegister;
begin
  Self.Request.Method := MethodAck;
  Check(not Self.Request.IsRegister, MethodAck);

  Self.Request.Method := MethodBye;
  Check(not Self.Request.IsRegister, MethodBye);

  Self.Request.Method := MethodCancel;
  Check(not Self.Request.IsRegister, MethodCancel);

  Self.Request.Method := MethodInvite;
  Check(not Self.Request.IsRegister, MethodInvite);

  Self.Request.Method := MethodOptions;
  Check(not Self.Request.IsRegister, MethodOptions);

  Self.Request.Method := MethodRegister;
  Check(Self.Request.IsRegister, MethodRegister);

  Self.Request.Method := 'XXX';
  Check(not Self.Request.IsRegister, 'XXX');
end;

procedure TestTIdSipRequest.TestIsRequest;
begin
  Check(Self.Request.IsRequest, 'IsRequest');
end;

procedure TestTIdSipRequest.TestMatchRFC2543Options;
var
  Options:  TIdSipRequest;
begin
  Options := TIdSipRequest.Create;
  try
    Options.Method := MethodOptions;
    Options.RequestUri.Uri := 'sip:franks@192.168.0.254';
    Options.AddHeader(ViaHeaderFull).Value  := 'SIP/2.0/UDP roke.angband.za.org:3442';
    Options.From.Value := '<sip:sipsak@roke.angband.za.org:3442>';
    Options.ToHeader.Value := '<sip:franks@192.168.0.254>';
    Options.CallID := '1631106896@roke.angband.za.org';
    Options.CSeq.Value := '1 OPTIONS';
    Options.AddHeader(ContactHeaderFull).Value := '<sip:sipsak@roke.angband.za.org:3442>';
    Options.ContentLength := 0;
    Options.MaxForwards := 0;
    Options.AddHeader(UserAgentHeader).Value := 'sipsak v0.8.1';

    Check(Options.Match(Options),
          'An RFC 2543 OPTIONS message should match itself!');
  finally
    Options.Free;
  end;
end;

procedure TestTIdSipRequest.TestMatchRFC2543Cancel;
var
  Cancel: TIdSipRequest;
  Invite: TIdSipRequest;
begin
  Invite := TIdSipRequest.Create;
  try
    Invite.Method := MethodInvite;
    Invite.RequestUri.Uri := 'sip:franks@192.168.0.254';
    Invite.AddHeader(ViaHeaderFull).Value  := 'SIP/2.0/UDP roke.angband.za.org:3442';
    Invite.From.Value := '<sip:sipsak@roke.angband.za.org:3442>';
    Invite.ToHeader.Value := '<sip:franks@192.168.0.254>';
    Invite.CallID := '1631106896@roke.angband.za.org';
    Invite.CSeq.Value := '1 Invite';
    Invite.AddHeader(ContactHeaderFull).Value := '<sip:sipsak@roke.angband.za.org:3442>';
    Invite.ContentLength := 0;
    Invite.MaxForwards := 0;
    Invite.AddHeader(UserAgentHeader).Value := 'sipsak v0.8.1';

    Cancel := Invite.CreateCancel;
    try
      Check(Invite.MatchCancel(Cancel), 'Matching CANCEL');

      Cancel.LastHop.Branch := Cancel.LastHop.Branch + '1';
      Check(not Invite.MatchCancel(Cancel), 'Non-matching CANCEL');
    finally
      Cancel.Free;
    end;
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipRequest.TestMatchCancel;
var
  Cancel: TIdSipRequest;
begin
  Cancel := Self.Request.CreateCancel;
  try
    Check(Self.Request.MatchCancel(Cancel), 'Matching CANCEL');

    Cancel.LastHop.Branch := Cancel.LastHop.Branch + '1';
    Check(not Self.Request.MatchCancel(Cancel), 'Non-matching CANCEL');
  finally
    Cancel.Free;
  end;
end;

procedure TestTIdSipRequest.TestMatchCancelAgainstAck;
var
  Ack:    TIdSipRequest;
  Cancel: TIdSipRequest;
begin
  Ack := Self.Request.AckFor(Self.Response);
  try
    Cancel := Self.Request.CreateCancel;
    try
      Check(Ack.MatchCancel(Cancel), '"Matching" CANCEL');

      Cancel.LastHop.Branch := Cancel.LastHop.Branch + '1';
      Check(not Ack.MatchCancel(Cancel), 'Non-"matching" CANCEL');
    finally
      Cancel.Free;
    end;
  finally
    Ack.Free;
  end;
end;

procedure TestTIdSipRequest.TestNewRequestHasContentLength;
var
  R: TIdSipRequest;
begin
  R := TIdSipRequest.Create;
  try
    Check(Pos(ContentLengthHeaderFull, R.AsString) > 0,
          'Content-Length missing from new request');
  finally
    R.Free;
  end;
end;

procedure TestTIdSipRequest.TestParse;
var
  Req: TIdSipRequest;
begin
  Req := TIdSipMessage.ReadRequestFrom(BasicRequest);
  try
    Self.CheckBasicRequest(Req);
  finally
    Req.Free;
  end;
end;

procedure TestTIdSipRequest.TestParseCompoundHeader;
const
  Route = 'Route: <sip:127.0.0.1>'#13#10
        + 'Route: wsfrank <sip:192.168.0.1>;low, <sip:192.168.0.1>'#13#10
        + BasicContentLengthHeader;
var
  Expected: TIdSipHeaders;
  Req: TIdSipRequest;
  Routes:   TIdSipHeadersFilter;
begin
  Req := TIdSipMessage.ReadRequestFrom(StringReplace(BasicRequest,
                                                     BasicContentLengthHeader,
                                                     Route,
                                                     []));
  try
    Expected := TIdSipHeaders.Create;
    try
      Expected.Add(RouteHeader).Value := '<sip:127.0.0.1>';
      Expected.Add(RouteHeader).Value := 'wsfrank <sip:192.168.0.1>;low';
      Expected.Add(RouteHeader).Value := '<sip:192.168.0.1>';

      Routes := TIdSipHeadersFilter.Create(Req.Headers, RouteHeader);
      try
        Check(Expected.Equals(Routes),
        'Routes not split into separate headers');
      finally
        Routes.Free;
      end;
    finally
      Expected.Free;
    end;
  finally
    Req.Free;
  end;
end;

procedure TestTIdSipRequest.TestParseFoldedHeader;
var
  Req: TIdSipRequest;
begin
  Req := TIdSipMessage.ReadRequestFrom('INVITE sip:wintermute@tessier-ashpool.co.luna SIP/2.0'#13#10
                            + 'Via: SIP/2.0/TCP gw1.leo-ix.org;branch=z9hG4bK776asdhds'#13#10
                            + 'Call-ID: a84b4c76e66710@gw1.leo-ix.org'#13#10
                            + 'Max-Forwards: 70'#13#10
                            + 'From: Case'#13#10
                            + ' <sip:case@fried.neurons.org>'#13#10
                            + #9';tag=1928301774'#13#10
                            + 'To: Wintermute <sip:wintermute@tessier-ashpool.co.luna>'#13#10
                            + 'CSeq: 8'#13#10
                            + '  INVITE'#13#10
                            + #13#10);
  try
    CheckEquals('From: Case <sip:case@fried.neurons.org>;tag=1928301774',
                Req.FirstHeader(FromHeaderFull).AsString,
                'From header');
  finally
    Req.Free;
  end;
end;

procedure TestTIdSipRequest.TestParseLeadingBlankLines;
var
  Req: TIdSipRequest;
begin
  Req := TIdSipMessage.ReadRequestFrom(#13#10#13#10 + BasicRequest);
  try
    Self.CheckBasicRequest(Req);
  finally
    Req.Free;
  end;
end;

procedure TestTIdSipRequest.TestParseMalformedRequestLine;
var
  Req: TIdSipRequest;
begin
  Req := TIdSipMessage.ReadRequestFrom('INVITE  sip:wintermute@tessier-ashpool.co.luna SIP/2.0'#13#10);
  try
    Check(Req.IsMalformed,
          'Malformed start line (too many spaces between Method and Request-URI) parsed without error');
    CheckEquals(RequestUriNoSpaces,
                Req.ParseFailReason,
                'Unexpected fail reason (too many spaces between Method and Request-URI)');
  finally
    Req.Free;
  end;

  Req := TIdSipMessage.ReadRequestFrom('INVITEsip:wintermute@tessier-ashpool.co.lunaSIP/2.0'#13#10);
  try
    Check(Req.IsMalformed,
          'Malformed start line (no spaces between Method and Request-URI) parsed without error');
    CheckEquals(Format(MalformedToken,
                       ['Method', 'INVITEsip:wintermute@tessier-ashpool.co.lunaSIP/2.0']),
                Req.ParseFailReason,
                'Unexpected fail reason (no spaces between Method and Request-URI)');
  finally
    Req.Free;
  end;

  Req := TIdSipMessage.ReadRequestFrom('sip:wintermute@tessier-ashpool.co.luna SIP/2.0');
  try
    Check(Req.IsMalformed,
          'Malformed start line (no Method) parsed without error');
    CheckEquals(Format(MalformedToken,
                       ['Method', 'sip:wintermute@tessier-ashpool.co.luna']),
                Req.ParseFailReason,
                'Unexpected fail reason (no Method)');
  finally
    Req.Free;
  end;

  Req := TIdSipMessage.ReadRequestFrom('INVITE'#13#10);
  try
    Check(Req.IsMalformed,
          'Malformed start line (no Request-URI, no SIP-Version) parsed without error');
    CheckEquals(RequestUriNoSpaces,
                Req.ParseFailReason,
                'Unexpected fail reason (no Request-URI, no SIP-Version)');
  finally
    Req.Free;
  end;

  Req := TIdSipMessage.ReadRequestFrom('INVITE sip:wintermute@tessier-ashpool.co.luna SIP/;2.0'#13#10);
  try
    Check(Req.IsMalformed,
          'Malformed start line (malformed SIP-Version) parsed without error');
    CheckEquals(Format(InvalidSipVersion,
                       ['SIP/;2.0']),
                Req.ParseFailReason,
                'Unexpected fail reason (malformed SIP-Version)');
  finally
    Req.Free;
  end;

  Req := TIdSipMessage.ReadRequestFrom('INVITE <sip:abc@80.168.137.82:5060> SIP/2.0'#13#10);
  try
    Check(Req.IsMalformed,
          'Malformed start line (Request-URI in angle brackets) parsed without error');
    CheckEquals(RequestUriNoAngleBrackets,
                Req.ParseFailReason,
                'Unexpected fail reason (Request-URI in angle brackets)');
  finally
    Req.Free;
  end;
end;

procedure TestTIdSipRequest.TestParseWithRequestUriInAngleBrackets;
var
  R: TIdSipRequest;
begin
  R := TIdSipMessage.ReadRequestFrom('INVITE <sip:foo> SIP/2.0'#13#10);
  try
    Self.AddRequiredHeaders(R);
    Check(R.IsMalformed,
          'Request not marked as malformed');

    CheckEquals(RequestUriNoAngleBrackets,
                R.ParseFailReason,
                'Unexpected error message');
  finally
    R.Free;
  end;
end;

procedure TestTIdSipRequest.TestRequiresResponse;
begin
  Self.Request.Method := MethodAck;
  Check(not Self.Request.RequiresResponse, 'ACKs don''t need responses');
  Self.Request.Method := MethodBye;
  Check(Self.Request.RequiresResponse, 'BYEs need responses');
  Self.Request.Method := MethodCancel;
  Check(Self.Request.RequiresResponse, 'CANCELs need responses');
  Self.Request.Method := MethodInvite;
  Check(Self.Request.RequiresResponse, 'INVITEs need responses');
  Self.Request.Method := MethodOptions;
  Check(Self.Request.RequiresResponse, 'OPTIONS need responses');
  Self.Request.Method := MethodRegister;
  Check(Self.Request.RequiresResponse, 'REGISTERs need responses');

  Self.Request.Method := 'NewFangledMethod';
  Check(Self.Request.RequiresResponse,
        'Unknown methods, by default (our assumption) require responses');
end;

procedure TestTIdSipRequest.TestSetMaxForwards;
var
  OrigMaxForwards: Byte;
begin
  OrigMaxForwards := Self.Request.MaxForwards;

  Self.Request.MaxForwards := Self.Request.MaxForwards + 1;

  CheckEquals(OrigMaxForwards + 1,
              Self.Request.MaxForwards,
              'Max-Forwards not set');
end;

procedure TestTIdSipRequest.TestSetRoute;
var
  H: TIdSipHeaders;
  P: TIdSipRoutePath;
begin
  Self.Request.AddHeader(RouteHeader).Value := '<sip:gw1.leo-ix.org>';

  H := TIdSipHeaders.Create;
  try
    H.Add(RouteHeader).Value := '<sip:gw2.leo-ix.org>';
    H.Add(RouteHeader).Value := '<sip:gw3.leo-ix.org;lr>';
    P := TIdSipRoutePath.Create(H);
    try
      Self.Request.Route := P;

      Check(Self.Request.Route.Equals(P), 'Path not correctly set');
    finally
      P.Free;
    end;
  finally
    H.Free;
  end;
end;

//******************************************************************************
//* TestTIdSipResponse                                                         *
//******************************************************************************
//* TestTIdSipResponse Public methods ******************************************

procedure TestTIdSipResponse.SetUp;
begin
  inherited SetUp;

  Self.Msg.SIPVersion := SIPVersion;
  (Self.Msg as TIdSipResponse).StatusCode := SIPTrying;

  Self.Request := TIdSipTestResources.CreateBasicRequest;

  Self.Contact := TIdSipContactHeader.Create;
  Self.Contact.Value := Self.Request.RequestUri.Uri;

  Self.Response := TIdSipResponse.Create;
end;

procedure TestTIdSipResponse.TearDown;
begin
  Self.Response.Free;
  Self.Contact.Free;
  Self.Request.Free;

  inherited TearDown;
end;

//* TestTIdSipResponse Protected methods ***************************************

function TestTIdSipResponse.MessageType: TIdSipMessageClass;
begin
  Result := TIdSipResponse;
end;

//* TestTIdSipResponse Private methods *****************************************

procedure TestTIdSipResponse.CheckBasicResponse(Msg: TIdSipMessage;
                                                CheckBody: Boolean = true);
begin
  CheckEquals(TIdSipResponse.Classname, Msg.ClassName, 'Class type');

  CheckEquals(486,         TIdSipResponse(Msg).StatusCode, 'StatusCode');
  CheckEquals('Busy Here', TIdSipResponse(Msg).StatusText, 'StatusText');
  CheckEquals(8,           Msg.HeaderCount,                'Header count');

  Self.CheckBasicMessage(Msg, CheckBody);
end;
//* TestTIdSipResponse Published methods ***************************************

procedure TestTIdSipResponse.TestAssign;
var
  R: TIdSipResponse;
begin
  R := TIdSipResponse.Create;
  try
    R.SIPVersion := 'SIP/1.5';
    R.StatusCode := 101;
    R.StatusText := 'Hehaeha I''ll get back to you';
    R.AddHeader(ViaHeaderFull).Value := 'SIP/2.0/TCP gw1.leo-ix.org;branch=z9hG4bK776asdhds';
    R.ContentLength := 5;
    R.Body := 'hello';

    Self.Response.Assign(R);
    CheckEquals(R.SIPVersion,    Self.Response.SipVersion,    'SIP-Version');
    CheckEquals(R.StatusCode,    Self.Response.StatusCode,    'Status-Code');
    CheckEquals(R.StatusText,    Self.Response.StatusText,    'Status-Text');

    Check(R.Headers.Equals(Self.Response.Headers),
          'Headers not assigned properly');
  finally
    R.Free;
  end;
end;

procedure TestTIdSipResponse.TestAssignBad;
var
  P: TPersistent;
begin
  P := TPersistent.Create;
  try
    try
      Self.Response.Assign(P);
      Fail('Failed to bail out assigning a TObject to a TIdSipResponse');
    except
      on EConvertError do;
    end;
  finally
    P.Free;
  end;
end;

procedure TestTIdSipResponse.TestAsString;
var
  Expected: TStrings;
  Received: TStrings;
  Res:      TIdSipResponse;
begin
  Self.Response.StatusCode                             := 486;
  Self.Response.StatusText                             := 'Busy Here';
  Self.Response.SIPVersion                             := SIPVersion;
  Self.Response.AddHeader(ViaHeaderFull).Value         := 'SIP/2.0/TCP gw1.leo-ix.org;branch=z9hG4bK776asdhds';
  Self.Response.AddHeader(ToHeaderFull).Value          := 'Wintermute <sip:wintermute@tessier-ashpool.co.luna>;tag=1928301775';
  Self.Response.AddHeader(FromHeaderFull).Value        := 'Case <sip:case@fried.neurons.org>;tag=1928301774';
  Self.Response.CallID                                 := 'a84b4c76e66710@gw1.leo-ix.org';
  Self.Response.AddHeader(CSeqHeader).Value            := '314159 INVITE';
  Self.Response.AddHeader(ContactHeaderFull).Value     := '<sip:wintermute@tessier-ashpool.co.luna>';
  Self.Response.AddHeader(ContentTypeHeaderFull).Value := 'text/plain';
  Self.Response.ContentLength                          := 29;
  Self.Response.Body                                   := 'I am a message. Hear me roar!';

  Expected := TStringList.Create;
  try
    Expected.Text := BasicResponse;

    Received := TStringList.Create;
    try
      Received.Text := Self.Response.AsString;

      CheckEquals(Expected, Received, 'AsString');

      Res := TIdSipMessage.ReadResponseFrom(Self.Response.AsString);
      try
        Check(not Res.IsMalformed, 'Sanity check AsString');
      finally
        Res.Free;
      end;
    finally
      Received.Free;
    end;
  finally
    Expected.Free;
  end;
end;

procedure TestTIdSipResponse.TestCopy;
var
  Copy: TIdSipMessage;
begin
  Copy := Self.Response.Copy;
  try
    Check(Copy.Equals(Self.Response), 'Copy = Self.Response');
    Check(Self.Response.Equals(Copy), 'Self.Response = Copy');
  finally
    Copy.Free;
  end;
end;

procedure TestTIdSipResponse.TestEqualsComplexMessages;
var
  R1, R2: TIdSipResponse;
begin
  R1 := TIdSipTestResources.CreateLocalLoopResponse;
  try
    R2 := TIdSipTestResources.CreateLocalLoopResponse;
    try
      Check(R1.Equals(R2), 'R1 = R2');
      Check(R2.Equals(R1), 'R2 = R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipResponse.TestEqualsDifferentHeaders;
var
  R1, R2: TIdSipResponse;
begin
  R1 := TIdSipResponse.Create;
  try
    R2 := TIdSipResponse.Create;
    try
      R1.AddHeader(ViaHeaderFull);

      Check(not R1.Equals(R2), 'R1 <> R2');
      Check(not R2.Equals(R1), 'R2 <> R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipResponse.TestEqualsDifferentSipVersion;
var
  R1, R2: TIdSipResponse;
begin
  R1 := TIdSipResponse.Create;
  try
    R2 := TIdSipResponse.Create;
    try
      R1.SIPVersion := 'SIP/2.0';
      R2.SIPVersion := 'SIP/2.1';

      Check(not R1.Equals(R2), 'R1 <> R2');
      Check(not R2.Equals(R1), 'R2 <> R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipResponse.TestEqualsDifferentStatusCode;
var
  R1, R2: TIdSipResponse;
begin
  R1 := TIdSipResponse.Create;
  try
    R2 := TIdSipResponse.Create;
    try
      R1.StatusCode := SIPOK;
      R2.StatusCode := SIPTrying;

      Check(not R1.Equals(R2), 'R1 <> R2');
      Check(not R2.Equals(R1), 'R2 <> R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipResponse.TestEqualsDifferentStatusText;
var
  R1, R2: TIdSipResponse;
begin
  R1 := TIdSipResponse.Create;
  try
    R2 := TIdSipResponse.Create;
    try
      R1.StatusText := RSSIPOK;
      R2.StatusText := RSSIPTrying;

      Check(not R1.Equals(R2), 'R1 <> R2');
      Check(not R2.Equals(R1), 'R2 <> R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipResponse.TestEqualsRequest;
var
  Req: TIdSipRequest;
  Res: TIdSipResponse;
begin
  Req := TIdSipRequest.Create;
  try
    Res := TIdSipResponse.Create;
    try
      Check(not Res.Equals(Req), 'Res <> Req');
    finally
      Res.Free;
    end;
  finally
    Req.Free;
  end;
end;

procedure TestTIdSipResponse.TestEqualsTrivial;
var
  R1, R2: TIdSipResponse;
begin
  R1 := TIdSipResponse.Create;
  try
    R2 := TIdSipResponse.Create;
    try
      Check(R1.Equals(R2), 'R1 = R2');
      Check(R2.Equals(R1), 'R2 = R1');
    finally
      R2.Free;
    end;
  finally
    R1.Free;
  end;
end;

procedure TestTIdSipResponse.TestFirstProxyAuthenticate;
var
  P: TIdSipHeader;
begin
  Self.Response.ClearHeaders;

  CheckNotNull(Self.Response.FirstProxyAuthenticate,
               'Proxy-Authenticate not present');
  CheckEquals(1,
              Self.Response.HeaderCount,
              'Proxy-Authenticate not auto-added');

  P := Self.Response.FirstHeader(ProxyAuthenticateHeader);
  Self.Response.AddHeader(ProxyAuthenticateHeader);

  Check(P = Self.Response.FirstProxyAuthenticate,
        'Wrong Proxy-Authenticate');
end;

procedure TestTIdSipResponse.TestFirstUnsupported;
var
  U: TIdSipHeader;
begin
  Self.Response.ClearHeaders;

  CheckNotNull(Self.Response.FirstUnsupported, 'Unsupported not present');
  CheckEquals(1, Self.Response.HeaderCount, 'Unsupported not auto-added');

  U := Self.Response.FirstHeader(UnsupportedHeader);
  Self.Response.AddHeader(UnsupportedHeader);

  Check(U = Self.Response.FirstUnsupported, 'Wrong Unsupported');
end;

procedure TestTIdSipResponse.TestFirstWarning;
var
  W: TIdSipHeader;
begin
  Self.Response.ClearHeaders;

  CheckNotNull(Self.Response.FirstWarning, 'Warning not present');
  CheckEquals(1, Self.Response.HeaderCount, 'Warning not auto-added');

  W := Self.Response.FirstHeader(WarningHeader);
  Self.Response.AddHeader(WarningHeader);

  Check(W = Self.Response.FirstWarning, 'Wrong Warning');
end;

procedure TestTIdSipResponse.TestFirstWWWAuthenticate;
var
  P: TIdSipHeader;
begin
  Self.Response.ClearHeaders;

  CheckNotNull(Self.Response.FirstWWWAuthenticate,
               'WWW-Authenticate not present');
  CheckEquals(1,
              Self.Response.HeaderCount,
              'WWW-Authenticate not auto-added');

  P := Self.Response.FirstHeader(WWWAuthenticateHeader);
  Self.Response.AddHeader(WWWAuthenticateHeader);

  Check(P = Self.Response.FirstWWWAuthenticate,
        'Wrong WWW-Authenticate');
end;

procedure TestTIdSipResponse.TestHasAuthenticationInfo;
begin
  Check(not Self.Response.HasHeader(AuthenticationInfoHeader),
        'Sanity check');

  Check(not Self.Response.HasAuthenticationInfo,
        'New response');


  Self.Response.AddHeader(AuthenticationInfoHeader);
  Check(Self.Response.HasAuthenticationInfo,
        'Lies! There is too an Authentication-Info header!');
end;

procedure TestTIdSipResponse.TestHasProxyAuthenticate;
begin
  Check(not Self.Response.HasHeader(ProxyAuthenticateHeader),
        'Sanity check');

  Check(not Self.Response.HasProxyAuthenticate,
        'New response');


  Self.Response.AddHeader(ProxyAuthenticateHeader);
  Check(Self.Response.HasProxyAuthenticate,
        'Lies! There is too a Proxy-Authenticate header!');
end;

procedure TestTIdSipResponse.TestHasWarning;
begin
  Check(not Self.Response.HasHeader(WarningHeader),
        'Sanity check');

  Check(not Self.Response.HasWarning,
        'New response');

  Self.Response.AddHeader(WarningHeader);
  Check(Self.Response.HasWarning,
        'Lies! There is too a Warning header!');
end;

procedure TestTIdSipResponse.TestHasWWWAuthenticate;
begin
  Check(not Self.Response.HasHeader(WWWAuthenticateHeader),
        'Sanity check');

  Check(not Self.Response.HasWWWAuthenticate,
        'New response');


  Self.Response.AddHeader(WWWAuthenticateHeader);
  Check(Self.Response.HasWWWAuthenticate,
        'Lies! There is too a WWW-Authenticate header!');
end;

procedure TestTIdSipResponse.TestInResponseToRecordRoute;
var
  RequestRecordRoutes:  TIdSipHeadersFilter;
  Response:             TIdSipResponse;
  ResponseRecordRoutes: TIdSipHeadersFilter;
begin
  Self.Request.AddHeader(RecordRouteHeader).Value := '<sip:127.0.0.1:6000>';
  Self.Request.AddHeader(RecordRouteHeader).Value := '<sip:127.0.0.1:6001>';
  Self.Request.AddHeader(RecordRouteHeader).Value := '<sip:127.0.0.1:6002>';

  RequestRecordRoutes := TIdSipHeadersFilter.Create(Self.Request.Headers, RecordRouteHeader);
  try
    Response := TIdSipResponse.InResponseTo(Self.Request, SIPOK, Contact);
    try
      ResponseRecordRoutes := TIdSipHeadersFilter.Create(Response.Headers, RecordRouteHeader);
      try
        Check(ResponseRecordRoutes.Equals(RequestRecordRoutes),
              'Record-Route header sets mismatch');
      finally
        ResponseRecordRoutes.Free;
      end;
    finally
      Response.Free;
    end;
  finally
    RequestRecordRoutes.Free;
  end;
end;

procedure TestTIdSipResponse.TestInResponseToSipsRecordRoute;
var
  Response:    TIdSipResponse;
  SipsContact: TIdSipContactHeader;
begin
  Self.Request.AddHeader(RecordRouteHeader).Value := '<sips:127.0.0.1:6000>';

  Response := TIdSipResponse.InResponseTo(Self.Request, SIPOK, Contact);
  try
    SipsContact := Response.FirstContact;
    CheckEquals(SipsScheme, SipsContact.Address.Scheme,
                'Must use a SIPS URI in the Contact');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipResponse.TestInResponseToSipsRequestUri;
var
  Response:    TIdSipResponse;
  SipsContact: TIdSipContactHeader;
begin
  Self.Request.RequestUri.URI := 'sips:wintermute@tessier-ashpool.co.luna';

  Response := TIdSipResponse.InResponseTo(Self.Request, SIPOK, Contact);
  try
    SipsContact := Response.FirstContact;
    CheckEquals(SipsScheme, SipsContact.Address.Scheme,
                'Must use a SIPS URI in the Contact');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipResponse.TestInResponseToTryingWithTimestamps;
var
  Response: TIdSipResponse;
begin
  Self.Request.AddHeader(TimestampHeader).Value := '1';

  Response := TIdSipResponse.InResponseTo(Self.Request, SIPTrying);
  try
    Check(Response.HasHeader(TimestampHeader),
          'Timestamp header(s) not copied');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipResponse.TestInResponseToWithContact;
var
  FromFilter: TIdSipHeadersFilter;
  P:          TIdSipParser;
  Response:   TIdSipResponse;
begin
  P := TIdSipParser.Create;
  try
    Response := TIdSipResponse.InResponseTo(Self.Request, SIPOK, Contact);
    try
      FromFilter := TIdSipHeadersFilter.Create(Response.Headers, FromHeaderFull);
      try
        CheckEquals(1, FromFilter.Count, 'Number of From headers');
      finally
        FromFilter.Free;
      end;

      CheckEquals(SIPOK, Response.StatusCode,        'StatusCode mismatch');
      Check(Response.CSeq.Equals(Self.Request.CSeq), 'Cseq header mismatch');
      Check(Response.From.Equals(Self.Request.From), 'From header mismatch');
      Check(Response.Path.Equals(Self.Request.Path), 'Via headers mismatch');

      Check(Request.ToHeader.Equals(Response.ToHeader),
            'To header mismatch');

      Check(Response.HasHeader(ContactHeaderFull), 'Missing Contact header');
    finally
      Response.Free;
    end;
  finally
    P.Free;
  end;
end;

procedure TestTIdSipResponse.TestIsAuthenticationChallenge;
var
  I: Integer;
begin
  for I := 100 to 400 do begin
    Self.Response.StatusCode := I;
    Check(not Self.Response.IsAuthenticationChallenge,
          IntToStr(Self.Response.StatusCode)
        + ' ' + Self.Response.StatusText);
  end;

  Self.Response.StatusCode := 401;
  Check(Self.Response.IsAuthenticationChallenge,
        IntToStr(Self.Response.StatusCode)
      + ' ' + Self.Response.StatusText);

  for I := 402 to 406 do begin
    Self.Response.StatusCode := I;
    Check(not Self.Response.IsAuthenticationChallenge,
          IntToStr(Self.Response.StatusCode)
        + ' ' + Self.Response.StatusText);
  end;

  Self.Response.StatusCode := 407;
  Check(Self.Response.IsAuthenticationChallenge,
        IntToStr(Self.Response.StatusCode)
      + ' ' + Self.Response.StatusText);

  for I := 408 to 699 do begin
    Self.Response.StatusCode := I;
    Check(not Self.Response.IsAuthenticationChallenge,
          IntToStr(I)
        + ' ' + Self.Response.StatusText);
  end;
end;

procedure TestTIdSipResponse.TestIsMalformedStatusCode;
var
  Res: TIdSipResponse;
begin
  Res := TIdSipMessage.ReadResponseFrom('SIP/2.0 Aheh OK'#13#10);
  try
    Check(Res.IsMalformed,
          'Failed to reject a non-numeric Status-Code');
    CheckEquals(Format(InvalidStatusCode, ['Aheh']),
                Res.ParseFailReason,
                'Unexpected parse fail reason');
  finally
    Res.Free;
  end;
end;

procedure TestTIdSipResponse.TestIsFinal;
var
  I: Integer;
begin
  for I := 100 to 199 do begin
    Self.Response.StatusCode := I;
    Check(not Self.Response.IsFinal,
          IntToStr(Self.Response.StatusCode)
        + ' ' + Self.Response.StatusText);
  end;

  for I := 200 to 699 do begin
    Self.Response.StatusCode := I;
    Check(Self.Response.IsFinal,
          IntToStr(Self.Response.StatusCode)
        + ' ' + Self.Response.StatusText);
  end;
end;

procedure TestTIdSipResponse.TestIsOK;
var
  I: Integer;
begin
  for I := 100 to 199 do begin
    Self.Response.StatusCode := I;
    Check(not Self.Response.IsOK,
          IntToStr(I) + ' ' + Self.Response.StatusText);
  end;

  for I := 200 to 299 do begin
    Self.Response.StatusCode := I;
    Check(Self.Response.IsOK,
          IntToStr(I) + ' ' + Self.Response.StatusText);
  end;

  for I := 301 to 699 do begin
    Self.Response.StatusCode := I;
    Check(not Self.Response.IsOK,
          IntToStr(I) + ' ' + Self.Response.StatusText);
  end;
end;

procedure TestTIdSipResponse.TestIsProvisional;
var
  I: Integer;
begin
  for I := 100 to 199 do begin
    Self.Response.StatusCode := I;
    Check(Self.Response.IsProvisional,
          IntToStr(Self.Response.StatusCode)
        + ' ' + Self.Response.StatusText);
  end;

  for I := 200 to 699 do begin
    Self.Response.StatusCode := I;
    Check(not Self.Response.IsProvisional,
          IntToStr(Self.Response.StatusCode)
        + ' ' + Self.Response.StatusText);
  end;
end;

procedure TestTIdSipResponse.TestIsRedirect;
var
  I: Integer;
begin
  for I := 100 to 299 do begin
    Self.Response.StatusCode := I;
    Check(not Self.Response.IsRedirect,
          IntToStr(Self.Response.StatusCode)
        + ' ' + Self.Response.StatusText);
  end;

  for I := 300 to 399 do begin
    Self.Response.StatusCode := I;
    Check(Self.Response.IsRedirect,
          IntToStr(Self.Response.StatusCode)
        + ' ' + Self.Response.StatusText);
  end;

  for I := 400 to 699 do begin
    Self.Response.StatusCode := I;
    Check(not Self.Response.IsRedirect,
          IntToStr(Self.Response.StatusCode)
        + ' ' + Self.Response.StatusText);
  end;
end;

procedure TestTIdSipResponse.TestIsRequest;
begin
  Check(not Self.Response.IsRequest, 'IsRequest');
end;

procedure TestTIdSipResponse.TestIsTrying;
var
  I: Integer;
begin
  for I := 101 to 699 do begin
    Self.Response.StatusCode := I;
    Check(not Self.Response.IsTrying,
          'StatusCode ' + IntToStr(Self.Response.StatusCode)
        + ' ' + Self.Response.StatusText);
  end;

  Self.Response.StatusCode := SIPTrying;
  Check(Self.Response.IsTrying, Self.Response.StatusText);
end;

procedure TestTIdSipResponse.TestParse;
var
  Res: TIdSipResponse;
begin
  Res := TIdSipMessage.ReadResponseFrom(BasicResponse);
  try
    Self.CheckBasicResponse(Res);
  finally
    Res.Free;
  end;
end;

procedure TestTIdSipResponse.TestParseEmptyString;
var
  Res: TIdSipResponse;
begin
  Res := TIdSipMessage.ReadResponseFrom('');
  try
    CheckEquals('', Res.SipVersion, 'Sip-Version');
    CheckEquals(0,  Res.StatusCode, 'Status-Code');
    CheckEquals('', Res.StatusText, 'Status-Text');
  finally
    Res.Free;
  end;
end;

procedure TestTIdSipResponse.TestParseFoldedHeader;
var
  Res: TIdSipResponse;
begin
  Res := TIdSipMessage.ReadResponseFrom('SIP/2.0 200 OK'#13#10
                          + 'From: Case'#13#10
                          + ' <sip:case@fried.neurons.org>'#13#10
                          + #9';tag=1928301774'#13#10
                          + 'To: Wintermute <sip:wintermute@tessier-ashpool.co.luna>'#13#10
                          + 'Via: SIP/2.0/TCP gw1.leo-ix.org'#13#10
                          + 'CSeq: 271828 INVITE'#13#10
                          + 'Call-ID: cafebabe@sip.neurons.org'#13#10
                          + #13#10);
  try
    CheckEquals('SIP/2.0', Res.SipVersion, 'SipVersion');
    CheckEquals(200,       Res.StatusCode, 'StatusCode');
    CheckEquals('OK',      Res.StatusText, 'StatusTest');

    CheckEquals('From: Case <sip:case@fried.neurons.org>;tag=1928301774',
                Res.From.AsString,
                'From header');
    CheckEquals('To: Wintermute <sip:wintermute@tessier-ashpool.co.luna>',
                Res.ToHeader.AsString,
                'To header');
  finally
    Res.Free;
  end;
end;

procedure TestTIdSipResponse.TestParseLeadingBlankLines;
var
  Res: TIdSipResponse;
begin
  Res := TIdSipMessage.ReadResponseFrom(#13#10#13#10 + BasicResponse);
  try
    Self.CheckBasicResponse(Res);
  finally
    Res.Free;
  end;
end;

//******************************************************************************
//* TestTIdSipResponseList                                                     *
//******************************************************************************
//* TestTIdSipResponseList Public methods **************************************

procedure TestTIdSipResponseList.SetUp;
begin
  inherited SetUp;

  Self.List := TIdSipResponseList.Create;
end;

procedure TestTIdSipResponseList.TearDown;
begin
  Self.List.Free;

  inherited TearDown;
end;

//* TestTIdSipResponseList Published methods ***********************************

procedure TestTIdSipResponseList.TestAddAndCount;
var
  Response: TIdSipResponse;
begin
  CheckEquals(0, Self.List.Count, 'Empty list');

  Response := TIdSipResponse.Create;
  try
    Self.List.AddCopy(Response);
    CheckEquals(1, Self.List.Count, 'One response');

    Self.List.AddCopy(Response);
    CheckEquals(2, Self.List.Count, 'Two responses');

    Self.List.AddCopy(Response);
    CheckEquals(3, Self.List.Count, 'Three responses');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipResponseList.TestDelete;
var
  Response: TIdSipResponse;
begin
  Response := TIdSipResponse.Create;
  try
    Response.StatusCode := SIPTrying;
    Self.List.AddCopy(Response);

    Response.StatusCode := SIPOK;
    Self.List.AddCopy(Response);

    Self.List.Delete(0);

    CheckEquals(1,
                Self.List.Count,
                'Nothing deleted');
    CheckEquals(SIPOK,
                Self.List.First.StatusCode,
                'Wrong response deleted');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipResponseList.TestFirst;
var
  Response: TIdSipResponse;
begin
  Response := TIdSipResponse.Create;
  try
    Response.StatusCode := SIPOK;

    Check(nil = Self.List.First,
          'Empty list');

    Self.List.AddCopy(Response);

    CheckEquals(SIPOK,
                Self.List.First.StatusCode,
                'Non-empty list');

    Response.StatusCode := SIPTrying;
    Self.List.AddCopy(Response);

    CheckEquals(SIPOK,
                Self.List.First.StatusCode,
                'List with multiple responses');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipResponseList.TestIsEmpty;
var
  Response: TIdSipResponse;
begin
  Check(Self.List.IsEmpty, 'Empty list');

  Response := TIdSipResponse.Create;
  try
    Self.List.AddCopy(Response);
    Check(not Self.List.IsEmpty, 'Non-empty list');
  finally
    Response.Free;
  end;

  Self.List.Delete(0);
  Check(Self.List.IsEmpty, 'Empty list after Delete');
end;

procedure TestTIdSipResponseList.TestLast;
var
  Response: TIdSipResponse;
begin
  Response := TIdSipResponse.Create;
  try
    Response.StatusCode := SIPOK;

    Check(nil = Self.List.First,
          'Empty list');

    Self.List.AddCopy(Response);

    CheckEquals(Response.StatusCode,
                Self.List.First.StatusCode,
                'Non-empty list');

    Response.StatusCode := SIPTrying;

    Self.List.AddCopy(Response);

    CheckEquals(Response.StatusCode,
                Self.List.Last.StatusCode,
                'List with multiple responses');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipResponseList.TestListStoresCopiesNotReferences;
var
  OriginalStatusCode: Cardinal;
  Response:           TIdSipResponse;
begin
  OriginalStatusCode := SIPOK;

  Response := TIdSipResponse.Create;
  try
    Response.StatusCode := OriginalStatusCode;

    Self.List.AddCopy(Response);

    Response.StatusCode := SIPNotFound;

    CheckEquals(OriginalStatusCode,
                Self.List.First.StatusCode,
                'List copy got mutated');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipResponseList.TestSecondLast;
var
  Response: TIdSipResponse;
begin
  Response := TIdSipResponse.Create;
  try
    Response.StatusCode := SIPTrying;

    Check(nil = Self.List.SecondLast,
          'Empty list');

    Self.List.AddCopy(Response);

    Check(nil = Self.List.SecondLast,
          'Non-empty list');

    Response.StatusCode := SIPOK;
    Self.List.AddCopy(Response);

    CheckEquals(SIPTrying,
                Self.List.SecondLast.StatusCode,
                'List with two responses');

    Response.StatusCode := SIPMultipleChoices;
    Self.List.AddCopy(Response);

    CheckEquals(SIPOK,
                Self.List.SecondLast.StatusCode,
                'List with three responses');
  finally
    Response.Free;
  end;
end;

initialization
  RegisterTest('SIP Messages', Suite);
end.
