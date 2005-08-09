{
  (c) 2005 Directorate of New Technologies, Royal National Institute for Deaf people (RNID)

  The RNID licence covers this unit. Read the licence at:
      http://www.ictrnid.org.uk/docs/gw/rnid_license.txt

  This unit contains code written by:
    * Frank Shearar
}
unit TestIdSipUserAgent;

interface

uses
  Classes, IdObservable, IdRTP, IdSdp, IdSipCore, IdSipDialog, IdSipDialogID,
  IdSipMessage, IdSipTransport, IdSocketHandle, IdUdpServer, IdSipUserAgent,
  IdTimerQueue, SyncObjs, TestFrameworkEx, TestFrameworkSip, TestFrameworkSipTU;

type
  TestTIdSipUserAgent = class(TTestCaseTU,
                              IIdObserver,
                              IIdSipActionListener,
                              IIdSipTransportSendingListener,
                              IIdSipSessionListener,
                              IIdSipTransactionUserListener,
                              IIdSipUserAgentListener)
  private
    Dlg:                 TIdSipDialog;
    FailReason:          String;
    ID:                  TIdSipDialogID;
    InboundCallMimeType: String;
    InboundCallOffer:    String;
    LocalSequenceNo:     Cardinal;
    LocalUri:            TIdSipURI;
    OnChangedEvent:      TEvent;
    OnEndedSessionFired: Boolean;
    OnInboundCallFired:  Boolean;
    Password:            String;
    RemoteSequenceNo:    Cardinal;
    RemoteTarget:        TIdSipURI;
    RemoteUri:           TIdSipURI;
    RouteSet:            TIdSipHeaders;
    SendEvent:           TEvent;
    Session:             TIdSipInboundSession;
    SessionEstablished:  Boolean;
    TryAgain:            Boolean;
    UserAgentParam:      TIdSipAbstractUserAgent;

    procedure CheckCommaSeparatedHeaders(const ExpectedValues: String;
                                         Header: TIdSipHeader;
                                         const Msg: String);
    procedure CheckCreateRequest(Dest: TIdSipToHeader;
                                 Request: TIdSipRequest);
    procedure OnAuthenticationChallenge(Action: TIdSipAction;
                                        Response: TIdSipResponse); overload;
    procedure OnAuthenticationChallenge(UserAgent: TIdSipAbstractUserAgent;
                                        Challenge: TIdSipResponse;
                                        var Username: String;
                                        var Password: String;
                                        var TryAgain: Boolean); overload;
    procedure OnChanged(Observed: TObject);
    procedure OnDroppedUnmatchedMessage(UserAgent: TIdSipAbstractUserAgent;
                                        Message: TIdSipMessage;
                                        Receiver: TIdSipTransport);
    procedure OnEndedSession(Session: TIdSipSession;
                             ErrorCode: Cardinal;
                             const Reason: String);
    procedure OnEstablishedSession(Session: TIdSipSession;
                                   const RemoteSessionDescription: String;
                                   const MimeType: String);
    procedure OnInboundCall(UserAgent: TIdSipUserAgent;
                            Session: TIdSipInboundSession);
    procedure OnModifiedSession(Session: TIdSipSession;
                                Answer: TIdSipResponse);
    procedure OnModifySession(Session: TIdSipSession;
                              const RemoteSessionDescription: String;
                              const MimeType: String);
    procedure OnNetworkFailure(Action: TIdSipAction;
                               ErrorCode: Cardinal;
                               const Reason: String);
    procedure OnProgressedSession(Session: TIdSipSession;
                                  Progress: TIdSipResponse);
    procedure OnSendRequest(Request: TIdSipRequest;
                            Sender: TIdSipTransport);
    procedure OnSendResponse(Response: TIdSipResponse;
                             Sender: TIdSipTransport);
    procedure ReceiveBye(Dialog: TIdSipDialog);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAcksDontMakeTransactions;
    procedure TestAcceptCallSchedulesResendOk;
    procedure TestActionsNotifyUAObservers;
    procedure TestAddAllowedContentType;
    procedure TestAddAllowedContentTypeMalformed;
    procedure TestAddAllowedLanguage;
    procedure TestAddAllowedLanguageLanguageAlreadyPresent;
    procedure TestAddAllowedMethod;
    procedure TestAddAllowedMethodMethodAlreadyPresent;
    procedure TestAddAllowedScheme;
    procedure TestAddAllowedSchemeSchemeAlreadyPresent;
    procedure TestAddModule;
    procedure TestAddObserver;
    procedure TestAddUserAgentListener;
    procedure TestByeWithAuthentication;
    procedure TestCallUsingProxy;
    procedure TestCancelNotifiesTU;
    procedure TestConcurrentCalls;
    procedure TestContentTypeDefault;
    procedure TestCreateOptions;
    procedure TestCreateRequest;
    procedure TestCreateRequestSipsRequestUri;
    procedure TestCreateRequestUserAgent;
    procedure TestCreateRequestWithTransport;
    procedure TestCreateResponseToTagMissing;
    procedure TestCreateResponseUserAgent;
    procedure TestCreateResponseUserAgentBlank;
    procedure TestDeclinedCallNotifiesListeners;
    procedure TestDestroyCallsModuleCleanups;
    procedure TestDialogLocalSequenceNoMonotonicallyIncreases;
    procedure TestDispatchToCorrectSession;
    procedure TestDoNotDisturb;
    procedure TestDontReAuthenticate;
    procedure TestHasUnknownAccept;
    procedure TestHasUnknownContentEncoding;
    procedure TestHasUnknownContentType;
    procedure TestInboundCall;
    procedure TestInviteExpires;
    procedure TestInviteRaceCondition;
    procedure TestIsMethodSupported;
    procedure TestIsSchemeAllowed;
    procedure TestLoopDetection;
    procedure TestMergedRequest;
    procedure TestModuleForString;
    procedure TestNextCallID;
    procedure TestNextTag;
    procedure TestNotificationOfNewSession;
    procedure TestNotificationOfNewSessionRobust;
    procedure TestNotifyOfChange;
    procedure TestOutboundCallAndByeToXlite;
    procedure TestOutboundInviteSessionProgressResends;
    procedure TestOutboundInviteDoesNotTerminateWhenNoResponse;
    procedure TestReceiveByeForUnmatchedDialog;
    procedure TestReceiveByeForDialog;
    procedure TestReceiveByeDestroysTerminatedSession;
    procedure TestReceiveByeWithoutTags;
    procedure TestReceiveOptions;
    procedure TestReceiveResponseWithMultipleVias;
    procedure TestRejectMalformedAuthorizedRequest;
    procedure TestRejectMethodNotAllowed;
    procedure TestRejectNoContact;
    procedure TestRejectUnauthorizedRequest;
    procedure TestRejectUnknownContentEncoding;
    procedure TestRejectUnknownContentLanguage;
    procedure TestRejectUnknownContentType;
    procedure TestRejectUnknownExtension;
    procedure TestRejectUnknownScheme;
    procedure TestRejectUnsupportedMethod;
    procedure TestRejectUnsupportedSipVersion;
    procedure TestRemoveObserver;
    procedure TestRemoveUserAgentListener;
    procedure TestRFC2543InviteCallFlow;
    procedure TestScheduleEventActionClosure;
    procedure TestSetContact;
    procedure TestSetContactMailto;
    procedure TestSetContactWildCard;
    procedure TestSetFrom;
    procedure TestSetFromMailto;
    procedure TestSimultaneousInAndOutboundCall;
    procedure TestTerminateAllCalls;
    procedure TestUnknownAcceptValue;
    procedure TestUnmatchedAckGetsDropped;
    procedure TestViaMatchesTransportParameter;
  end;

  TestTIdSipStackConfigurator = class(TThreadingTestCase)
  private
    Address:        String;
    Conf:           TIdSipStackConfigurator;
    Configuration:  TStrings;
    Port:           Cardinal;
    ReceivedPacket: Boolean;
    Timer:          TIdTimerQueue;
    Server:         TIdUdpServer;

    function  ARecords: String;
    procedure CheckAutoContact(UserAgent: TIdSipAbstractUserAgent);
    procedure NoteReceiptOfPacket(Sender: TObject;
                                  AData: TStream;
                                  ABinding: TIdSocketHandle);
    procedure ProvideAnswer(Sender: TObject;
                            AData: TStream;
                            ABinding: TIdSocketHandle);

  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCreateUserAgentHandlesMultipleSpaces;
    procedure TestCreateUserAgentHandlesTabs;
    procedure TestCreateUserAgentRegisterDirectiveBeforeTransport;
    procedure TestCreateUserAgentReturnsSomething;
    procedure TestCreateUserAgentWithAutoTransport;
    procedure TestCreateUserAgentWithAutoContact;
    procedure TestCreateUserAgentWithContact;
    procedure TestCreateUserAgentWithFrom;
    procedure TestCreateUserAgentWithLocator;
    procedure TestCreateUserAgentWithMalformedContact;
    procedure TestCreateUserAgentWithMalformedFrom;
    procedure TestCreateUserAgentWithMalformedLocator;
    procedure TestCreateUserAgentWithMalformedProxy;
    procedure TestCreateUserAgentWithMockAuthenticator;
    procedure TestCreateUserAgentWithMockLocator;
    procedure TestCreateUserAgentWithNoContact;
    procedure TestCreateUserAgentWithNoFrom;
    procedure TestCreateUserAgentWithProxy;
    procedure TestCreateUserAgentWithRegistrar;
    procedure TestCreateUserAgentWithOneTransport;
    procedure TestCreateUserAgentTransportHaMalformedPort;
  end;

  TestTIdSipInviteModule = class(TTestCaseTU)
  private
    Dlg:    TIdSipDialog;
    Module: TIdSipInviteModule;
  public
    procedure SetUp; override;

    procedure CheckCommaSeparatedHeaders(const ExpectedValues: String;
                                         Header: TIdSipHeader;
                                         const Msg: String);
    procedure CheckCreateRequest(Dest: TIdSipToHeader;
                                 Request: TIdSipRequest);
  published
    procedure TestCreateAck;
    procedure TestCreateBye;
    procedure TestCreateInvite;
    procedure TestCreateInviteInsideDialog;
    procedure TestCreateInviteWithBody;
    procedure TestCreateReInvite;
  end;

  TestTIdSipInboundInvite = class(TestTIdSipAction,
                                  IIdSipInboundInviteListener)
  private
    Answer:         String;
    AnswerMimeType: String;
    Dialog:         TIdSipDialog;
    Failed:         Boolean;
    InviteAction:   TIdSipInboundInvite;
    Module:         TIdSipInviteModule;
    OnSuccessFired: Boolean;
    ToTag:          String;

    procedure CheckAck(InviteAction: TIdSipInboundInvite);
    procedure CheckAckWithDifferentCSeq(InviteAction: TIdSipInboundInvite);
    procedure OnFailure(InviteAgent: TIdSipInboundInvite);
    procedure OnSuccess(InviteAgent: TIdSipInboundInvite;
                        Ack: TIdSipRequest);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAccept;
    procedure TestCancelAfterAccept;
    procedure TestCancelBeforeAccept;
    procedure TestInviteWithNoOffer;
    procedure TestIsInbound; override;
    procedure TestIsInvite; override;
    procedure TestIsOptions; override;
    procedure TestIsRegistration; override;
    procedure TestIsSession; override;
    procedure TestMatchAck;
    procedure TestMatchAckToReInvite;
    procedure TestMatchAckToReInviteWithDifferentCSeq;
    procedure TestMatchAckWithDifferentCSeq;
    procedure TestMethod;
    procedure TestNotifyOfNetworkFailure;
    procedure TestNotifyOfSuccess;
    procedure TestReceiveResentAck;
    procedure TestRedirectCall;
    procedure TestRedirectCallPermanent;
    procedure TestRejectCallBusy;
    procedure TestResendOk;
    procedure TestRing;
    procedure TestSendSessionProgress;
    procedure TestTerminateAfterAccept;
    procedure TestTerminateBeforeAccept;
    procedure TestTimeOut;
  end;

  TestTIdSipOutboundInvite = class(TestTIdSipAction,
                                   IIdSipInviteListener,
                                   IIdSipTransactionUserListener,
                                   IIdSipUserAgentListener)
  private
    Dialog:                   TIdSipDialog;
    DroppedUnmatchedResponse: Boolean;
    InviteMimeType:           String;
    InviteOffer:              String;
    OnCallProgressFired:      Boolean;
    OnDialogEstablishedFired: Boolean;
    OnFailureFired:           Boolean;
    OnRedirectFired:          Boolean;
    OnSuccessFired:           Boolean;
    ToHeaderTag:              String;

    procedure CheckReceiveFailed(StatusCode: Cardinal);
    procedure CheckReceiveOk(StatusCode: Cardinal);
    procedure CheckReceiveProvisional(StatusCode: Cardinal);
    procedure CheckReceiveRedirect(StatusCode: Cardinal);
    function  CreateArbitraryDialog: TIdSipDialog;
    procedure OnAuthenticationChallenge(UserAgent: TIdSipAbstractUserAgent;
                                        Challenge: TIdSipResponse;
                                        var Username: String;
                                        var Password: String;
                                        var TryAgain: Boolean); overload;
    procedure OnCallProgress(InviteAgent: TIdSipOutboundInvite;
                        Response: TIdSipResponse);
    procedure OnDialogEstablished(InviteAgent: TIdSipOutboundInvite;
                                  NewDialog: TidSipDialog);
    procedure OnDroppedUnmatchedMessage(UserAgent: TIdSipAbstractUserAgent;
                                        Message: TIdSipMessage;
                                        Receiver: TIdSipTransport);
    procedure OnFailure(InviteAgent: TIdSipOutboundInvite;
                        Response: TIdSipResponse;
                        const Reason: String);
    procedure OnInboundCall(UserAgent: TIdSipUserAgent;
                            Session: TIdSipInboundSession);
    procedure OnRedirect(Invite: TIdSipOutboundInvite;
                         Response: TIdSipResponse);
    procedure OnSuccess(InviteAgent: TIdSipOutboundInvite;
                        Response: TIdSipResponse);
  protected
    function CreateAction: TIdSipAction; override;
    function CreateInitialInvite: TIdSipOutboundInitialInvite;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAddListener;
    procedure TestAnswerInAck;
    procedure TestCancelAfterAccept;
    procedure TestCancelBeforeAccept;
    procedure TestCancelBeforeProvisional;
    procedure TestCancelReceiveInviteOkBeforeCancelOk;
    procedure TestInviteTwice;
    procedure TestIsInvite; override;
    procedure TestMethod;
    procedure TestOfferInInvite;
    procedure TestReceive2xxSchedulesTransactionCompleted;
    procedure TestReceiveProvisional;
    procedure TestReceiveGlobalFailed;
    procedure TestReceiveOk;
    procedure TestReceiveRedirect;
    procedure TestReceiveRequestFailed;
    procedure TestReceiveRequestFailedAfterAckSent;
    procedure TestReceiveServerFailed;
    procedure TestRemoveListener;
    procedure TestSendTwice;
    procedure TestTerminateBeforeAccept;
    procedure TestTerminateAfterAccept;
    procedure TestTransactionCompleted;
  end;

  TestTIdSipOutboundRedirectedInvite = class(TestTIdSipOutboundInvite)
  private
    function CreateInvite: TIdSipOutboundRedirectedInvite;
  protected
    function CreateAction: TIdSipAction; override;
  published
    procedure TestRedirectedInvite;
  end;

  TestTIdSipOutboundReInvite = class(TestTIdSipOutboundInvite)
  private
    Dialog: TIdSipDialog;

    function CreateInvite: TIdSipOutboundReInvite;
  protected
    function CreateAction: TIdSipAction; override;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  TestTIdSipSession = class(TestTIdSipAction,
                            IIdSipSessionListener)
  protected
    ErrorCode:                 Cardinal;
    MimeType:                  String;
    Module:                    TIdSipInviteModule;
    MultiStreamSdp:            TIdSdpPayload;
    OnEndedSessionFired:       Boolean;
    OnEstablishedSessionFired: Boolean;
    OnModifiedSessionFired:    Boolean;
    OnModifySessionFired:      Boolean;
    Reason:                    String;
    RemoteSessionDescription:  String;
    SimpleSdp:                 TIdSdpPayload;

    procedure CheckResendWaitTime(Milliseconds: Cardinal;
                                  const Msg: String); virtual;
    function  CreateAndEstablishSession: TIdSipSession;
    function  CreateMultiStreamSdp: TIdSdpPayload;
    function  CreateRemoteReInvite(LocalDialog: TIdSipDialog): TIdSipRequest;
    function  CreateSimpleSdp: TIdSdpPayload;
    procedure EstablishSession(Session: TIdSipSession); virtual; abstract;
    procedure OnEndedSession(Session: TIdSipSession;
                             ErrorCode: Cardinal;
                             const Reason: String); virtual;
    procedure OnEstablishedSession(Session: TIdSipSession;
                                   const RemoteSessionDescription: String;
                                   const MimeType: String); virtual;
    procedure OnModifiedSession(Session: TIdSipSession;
                                Answer: TIdSipResponse); virtual;
    procedure OnModifySession(Session: TIdSipSession;
                              const RemoteSessionDescription: String;
                              const MimeType: String); virtual;
    procedure OnProgressedSession(Session: TIdSipSession;
                                  Progress: TIdSipResponse); virtual;
    procedure ReceiveRemoteReInvite(Session: TIdSipSession);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAckToInDialogInviteMatchesInvite;
    procedure TestDontMatchResponseToModify;
    procedure TestDontMatchResponseToInitialRequest;
    procedure TestInboundModify;
    procedure TestIsSession; override;
    procedure TestMatchBye;
    procedure TestMatchInitialRequest;
    procedure TestMatchInboundModify;
    procedure TestModify;
    procedure TestModifyBeforeFullyEstablished;
    procedure TestModifyDuringModification;
    procedure TestModifyGlareInbound;
    procedure TestModifyGlareOutbound;
    procedure TestModifyRejected;
    procedure TestModifyRejectedWithTimeout;
    procedure TestModifyWaitTime;
    procedure TestReceiveByeWithPendingRequests;
    procedure TestRejectInviteWhenInboundModificationInProgress;
    procedure TestRejectInviteWhenOutboundModificationInProgress;
    procedure TestRemodify;
  end;

  TestTIdSipInboundSession = class(TestTIdSipSession,
                                   IIdRTPDataListener,
                                   IIdSipTransportSendingListener,
                                   IIdSipUserAgentListener)
  private
    RemoteContentType:      String;
    RemoteDesc:             String;
    SentRequestTerminated:  Boolean;
    Session:                TIdSipInboundSession;

    procedure OnAuthenticationChallenge(UserAgent: TIdSipAbstractUserAgent;
                                        Challenge: TIdSipResponse;
                                        var Username: String;
                                        var Password: String;
                                        var TryAgain: Boolean); overload;
    procedure OnDroppedUnmatchedMessage(UserAgent: TIdSipAbstractUserAgent;
                                        Message: TIdSipMessage;
                                        Receiver: TIdSipTransport);
    procedure OnInboundCall(UserAgent: TIdSipUserAgent;
                            Session: TIdSipInboundSession);
    procedure OnNewData(Data: TIdRTPPayload;
                        Binding: TIdConnection);
    procedure OnSendRequest(Request: TIdSipRequest;
                            Sender: TIdSipTransport);
    procedure OnSendResponse(Response: TIdSipResponse;
                             Sender: TIdSipTransport);
    procedure ReceiveAckWithBody(const SessionDesc,
                                 ContentType: String);
  protected
    procedure CheckResendWaitTime(Milliseconds: Cardinal;
                                  const Msg: String); override;
    function  CreateAction: TIdSipAction; override;
    procedure EstablishSession(Session: TIdSipSession); override;
    procedure OnEndedSession(Session: TIdSipSession;
                             ErrorCode: Cardinal;
                             const Reason: String); override;
    procedure OnEstablishedSession(Session: TIdSipSession;
                                   const RemoteSessionDescription: String;
                                   const MimeType: String); override;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAcceptCall;
    procedure TestAddSessionListener;
    procedure TestCancelAfterAccept;
    procedure TestCancelBeforeAccept;
    procedure TestCancelNotifiesSession;
    procedure TestInviteHasNoOffer;
    procedure TestInviteHasOffer;
    procedure TestIsInbound; override;
    procedure TestIsOutboundCall;
    procedure TestMethod;
    procedure TestNotifyListenersOfEstablishedSession;
    procedure TestNotifyListenersOfEstablishedSessionInviteHasNoBody;
    procedure TestInboundModifyBeforeFullyEstablished;
    procedure TestInboundModifyReceivesNoAck;
    procedure TestReceiveBye;
    procedure TestReceiveOutOfOrderReInvite;
    procedure TestRedirectCall;
    procedure TestRejectCallBusy;
    procedure TestRemoveSessionListener;
    procedure TestTerminate;
    procedure TestTerminateUnestablishedSession;
  end;

  TestTIdSipOutboundSession = class(TestTIdSipSession,
                                    IIdSipTransactionUserListener,
                                    IIdSipUserAgentListener)
  private
    LocalMimeType:            String;
    LocalDescription:         String;
    OnDroppedMessage:         Boolean;
    OnProgressedSessionFired: Boolean;
    RemoteDesc:               String;
    RemoteMimeType:           String;
    Session:                  TIdSipOutboundSession;

    procedure OnAuthenticationChallenge(UserAgent: TIdSipAbstractUserAgent;
                                        Challenge: TIdSipResponse;
                                        var Username: String;
                                        var Password: String;
                                        var TryAgain: Boolean);
    procedure OnDroppedUnmatchedMessage(UserAgent: TIdSipAbstractUserAgent;
                                        Message: TIdSipMessage;
                                        Receiver: TIdSipTransport);
    procedure OnInboundCall(UserAgent: TIdSipUserAgent;
                            Session: TIdSipInboundSession);
    procedure ReceiveBusyHere(Invite: TIdSipRequest);
    procedure ReceiveForbidden;
    procedure ReceiveMovedTemporarily(Invite: TIdSipRequest;
                                      const Contacts: array of String); overload;
    procedure ReceiveMovedTemporarily(const Contact: String); overload;
    procedure ReceiveMovedTemporarily(const Contacts: array of String); overload;
    procedure ReceiveOKWithRecordRoute;
    procedure ReceiveRemoteDecline;    
  protected
    MimeType: String;
    SDP:      String;

    procedure CheckResendWaitTime(Milliseconds: Cardinal;
                                  const Msg: String); override;
    function  CreateAction: TIdSipAction; override;
    procedure EstablishSession(Session: TIdSipSession); override;
    procedure OnEstablishedSession(Session: TIdSipSession;
                                   const RemoteSessionDescription: String;
                                   const MimeType: String); override;
    procedure OnProgressedSession(Session: TIdSipSession;
                                  Progress: TIdSipResponse); override;
  public
    procedure SetUp; override;
  published
    procedure TestAck;
    procedure TestAckFromRecordRouteResponse;
    procedure TestAckWithAuthorization;
    procedure TestAckWithProxyAuthorization;
    procedure TestCall;
    procedure TestCallNetworkFailure;
    procedure TestCallRemoteRefusal;
    procedure TestCallSecure;
    procedure TestCallSipsUriOverTcp;
    procedure TestCallSipUriOverTls;
    procedure TestCallWithOffer;
    procedure TestCallWithoutOffer;
    procedure TestCancelReceiveInviteOkBeforeCancelOk;
    procedure TestCircularRedirect;
    procedure TestDialogNotEstablishedOnTryingResponse;
    procedure TestDoubleRedirect;
    procedure TestEmptyTargetSetMeansTerminate;
    procedure TestEstablishedSessionSetsInitialRequestToTag;
    procedure TestGlobalFailureEndsSession;
    procedure TestHangUp;
    procedure TestIsOutboundCall;
    procedure TestMethod;
    procedure TestModifyUsesAuthentication;
    procedure TestNetworkFailuresLookLikeSessionFailures;
    procedure TestReceive1xxNotifiesListeners;
    procedure TestReceive2xxSendsAck;
    procedure TestReceive3xxSendsNewInvite;
    procedure TestReceive3xxWithOneContact;
    procedure TestReceive3xxWithNoContacts;
    procedure TestReceiveFailureResponseAfterSessionEstablished;
    procedure TestReceiveFailureResponseNotifiesOnce;
    procedure TestReceiveFailureSetsReason;
    procedure TestReceiveFinalResponseSendsAck;
    procedure TestRedirectAndAccept;
    procedure TestRedirectMultipleOks;
    procedure TestRedirectNoMoreTargets;
    procedure TestRedirectWithMultipleContacts;
    procedure TestRedirectWithNoSuccess;
    procedure TestSendSetsInitialRequest;
    procedure TestTerminateDuringRedirect;
    procedure TestTerminateEstablishedSession;
    procedure TestTerminateNetworkFailure;
    procedure TestTerminateUnestablishedSession;
  end;

  TInviteMethodTestCase = class(TActionMethodTestCase)
  private
    Invite:   TIdSipOutboundInvite;
    Listener: TIdSipTestInviteListener;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  TestTIdSipInviteCallProgressMethod = class(TInviteMethodTestCase)
  private
    Method: TIdSipInviteCallProgressMethod;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRun;
  end;

  TestTIdSipInboundInviteFailureMethod = class(TActionMethodTestCase)
  private
    Invite: TIdSipRequest;
    Method: TIdSipInboundInviteFailureMethod;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRun;
  end;

  TestTIdSipInviteDialogEstablishedMethod = class(TActionMethodTestCase)
  private
    Method: TIdSipInviteDialogEstablishedMethod;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRun;
  end;

  TestInviteMethod = class(TActionMethodTestCase)
  private
    Invite:   TIdSipOutboundInvite;
    Listener: TIdSipTestInviteListener;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  TestTIdSipInviteFailureMethod = class(TestInviteMethod)
  private
    Method: TIdSipInviteFailureMethod;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRun;
  end;

  TestTIdSipInviteRedirectMethod = class(TestInviteMethod)
  private
    Method: TIdSipInviteRedirectMethod;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Run;
  end;

  TestTIdSipInviteSuccessMethod = class(TestInviteMethod)
  private
    Method: TIdSipInviteSuccessMethod;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRun;
  end;

  TestSessionMethod = class(TActionMethodTestCase)
  protected
    Listener: TIdSipTestSessionListener;
    Session:  TIdSipSession;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  end;

  TestTIdSipEndedSessionMethod = class(TestSessionMethod)
  private
    Method: TIdSipEndedSessionMethod;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRun;
  end;

  TestTIdSipEstablishedSessionMethod = class(TestSessionMethod)
  private
    Method: TIdSipEstablishedSessionMethod;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRun;
  end;

  TestTIdSipModifiedSessionMethod = class(TestSessionMethod)
  private
    Answer: TIdSipResponse;
    Method: TIdSipModifiedSessionMethod;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRun;
  end;

  TestTIdSipSessionModifySessionMethod = class(TestSessionMethod)
  private
    Session: TIdSipOutboundSession;
    Method:  TIdSipSessionModifySessionMethod;
  public
    procedure SetUp; override;
  published
    procedure TestRun;
  end;

  TestTIdSipProgressedSessionMethod = class(TestSessionMethod)
  private
    Method:   TIdSipProgressedSessionMethod;
    Progress: TIdSipResponse;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRun;
  end;

implementation

uses
  IdException, IdSimpleParser, IdSipAuthentication, IdSipMockLocator,
  IdSipMockTransport, IdSipRegistration, IdSipSubscribeModule, IdSystem,
  IdUnicode, SysUtils, TestFramework;

const
  // SFTF: Sip Foundry Test Framework. cf. http://www.sipfoundry.org/sftf/
  SFTFInvite = 'INVITE sip:abc@80.168.137.82 SIP/2.0'#13#10
             + 'Via: SIP/2.0/UDP 81.86.64.25;branch=z9hG4bK-SCb-0-1105373135.55-81.86.64.25-first-request;rport=5060;received=81.86.64.25'#13#10
             + 'Via: SIP/2.0/UDP proxy1.example.com;branch=z9hG4bK-SCb-0-1105373135.55-81.86.64.25-proxy1-request1-fake'#13#10
             + 'Via: SIP/2.0/UDP ua.example.com;branch=z9hG4bK-SCb-0-1105373135.55-81.86.64.25-ua-request-fake'#13#10
             + 'From: sip:sc@81.86.64.25;tag=SCt-0-1105373135.56-81.86.64.25~case905'#13#10
             + 'Call-ID: 137057836-41e2a7cf@81.86.64.25'#13#10
             + 'Content-Length: 150'#13#10
             + 'Max-Forwards: 70'#13#10
             + 'To: sip:abc@80.168.137.82'#13#10
             + 'Contact: sip:sc@81.86.64.25'#13#10
             + 'CSeq: 1 INVITE'#13#10
             + 'Supported:'#13#10
             + 'Content-Type: application/sdp'#13#10
             + #13#10
             + 'v=0'#13#10
             + 'o=sc 1105373135 1105373135 IN IP4 81.86.64.25'#13#10
             + 's=Dummy on hold SDP'#13#10
             + 'c=IN IP4 0.0.0.0'#13#10
             + 'm=audio 65534 RTP/AVP 0'#13#10
             + 'a=rtpmap:0 PCMU/8000'#13#10
             + 'a=recvonly'#13#10;
  SFTFMergedInvite = 'INVITE sip:abc@80.168.137.82 SIP/2.0'#13#10
                   + 'Via: SIP/2.0/UDP 81.86.64.25;branch=z9hG4bK-SCb-0-1105373135.55-81.86.64.25-second-request;rport=5060;received=81.86.64.25'#13#10
                   + 'Via: SIP/2.0/UDP proxy2.example.com;branch=z9hG4bK-SCb-0-1105373135.55-81.86.64.25-proxy2-request1-fake'#13#10
                   + 'Via: SIP/2.0/UDP ua.example.com;branch=z9hG4bK-SCb-0-1105373135.55-81.86.64.25-ua-request-fake'#13#10
                   + 'From: sip:sc@81.86.64.25;tag=SCt-0-1105373135.56-81.86.64.25~case905'#13#10
                   + 'Call-ID: 137057836-41e2a7cf@81.86.64.25'#13#10
                   + 'Content-Length: 150'#13#10
                   + 'Max-Forwards: 70'#13#10
                   + 'To: sip:abc@80.168.137.82'#13#10
                   + 'Contact: sip:sc@81.86.64.25'#13#10
                   + 'CSeq: 1 INVITE'#13#10
                   + 'Supported:'#13#10
                   + 'Content-Type: application/sdp'#13#10
                   + #13#10
                   + 'v=0'#13#10
                   + 'o=sc 1105373135 1105373135 IN IP4 81.86.64.25'#13#10
                   + 's=Dummy on hold SDP'#13#10
                   + 'c=IN IP4 0.0.0.0'#13#10
                   + 'm=audio 65534 RTP/AVP 0'#13#10
                   + 'a=rtpmap:0 PCMU/8000'#13#10
                   + 'a=recvonly'#13#10;

type
  TIdSipCoreWithExposedNotify = class(TIdSipAbstractUserAgent)
  public
    procedure TriggerNotify;
  end;

function Suite: ITestSuite;
begin
  Result := TTestSuite.Create('IdSipUserAgent unit tests');
  Result.AddTest(TestTIdSipUserAgent.Suite);
  Result.AddTest(TestTIdSipStackConfigurator.Suite);
  Result.AddTest(TestTIdSipInviteModule.Suite);
  Result.AddTest(TestTIdSipInboundInvite.Suite);
  Result.AddTest(TestTIdSipOutboundInvite.Suite);
  Result.AddTest(TestTIdSipOutboundRedirectedInvite.Suite);
  Result.AddTest(TestTIdSipOutboundReInvite.Suite);
  Result.AddTest(TestTIdSipInboundSession.Suite);
  Result.AddTest(TestTIdSipOutboundSession.Suite);
  Result.AddTest(TestTIdSipInviteCallProgressMethod.Suite);
  Result.AddTest(TestTIdSipInboundInviteFailureMethod.Suite);
  Result.AddTest(TestTIdSipInviteDialogEstablishedMethod.Suite);
  Result.AddTest(TestTIdSipInviteFailureMethod.Suite);
  Result.AddTest(TestTIdSipInviteRedirectMethod.Suite);
  Result.AddTest(TestTIdSipInviteSuccessMethod.Suite);
  Result.AddTest(TestTIdSipEndedSessionMethod.Suite);
  Result.AddTest(TestTIdSipEstablishedSessionMethod.Suite);
  Result.AddTest(TestTIdSipModifiedSessionMethod.Suite);
  Result.AddTest(TestTIdSipSessionModifySessionMethod.Suite);
end;

//******************************************************************************
//* TIdSipCoreWithExposedNotify                                                *
//******************************************************************************
//* TIdSipCoreWithExposedNotify Public methods *********************************

procedure TIdSipCoreWithExposedNotify.TriggerNotify;
begin
  Self.NotifyOfChange;
end;

//******************************************************************************
//* TestTIdSipUserAgent                                                        *
//******************************************************************************
//* TestTIdSipUserAgent Public methods *****************************************

procedure TestTIdSipUserAgent.SetUp;
var
  C:        TIdSipContactHeader;
  F:        TIdSipFromHeader;
  Invite:   TIdSipRequest;
  Response: TIdSipResponse;
begin
  inherited SetUp;

  Self.Dispatcher.AddTransportSendingListener(Self);

  Self.OnChangedEvent := TSimpleEvent.Create;

  Self.Core.AddUserAgentListener(Self);

  Self.ID := TIdSipDialogID.Create('1', '2', '3');

  Self.LocalSequenceNo := 13;
  Self.LocalUri        := TIdSipURI.Create('sip:case@fried.neurons.org');
  Self.LocalSequenceNo := 42;
  Self.RemoteTarget    := TIdSipURI.Create('sip:sip-proxy1.tessier-ashpool.co.luna');
  Self.RemoteUri       := TIdSipURI.Create('sip:wintermute@tessier-ashpool.co.luna');

  Self.RouteSet := TIdSipHeaders.Create;
  Self.RouteSet.Add(RecordRouteHeader).Value := '<sip:127.0.0.1>';
  Self.RouteSet.Add(RecordRouteHeader).Value := '<sip:127.0.0.1:6000>';
  Self.RouteSet.Add(RecordRouteHeader).Value := '<sip:127.0.0.1:8000>';

  Invite := TIdSipTestResources.CreateBasicRequest;
  try
    Response := TIdSipTestResources.CreateBasicResponse;
    try
      Self.Dlg := TIdSipDialog.Create(Invite,
                                      Response,
                                      Self.ID,
                                      Self.LocalSequenceNo,
                                      Self.RemoteSequenceNo,
                                      Self.LocalUri,
                                      Self.RemoteUri,
                                      Self.RemoteTarget,
                                      false,
                                      Self.RouteSet);
    finally
      Response.Free;
    end;
  finally
    Invite.Free;
  end;

  C := TIdSipContactHeader.Create;
  try
    C.Value := 'sip:wintermute@tessier-ashpool.co.luna';
    Self.Core.Contact := C;
  finally
    C.Free;
  end;

  F := TIdSipFromHeader.Create;
  try
    F.Value := 'Wintermute <sip:wintermute@tessier-ashpool.co.luna>';
    Self.Core.From := F;
  finally
    F.Free;
  end;

  Self.SendEvent := TSimpleEvent.Create;

  Self.OnEndedSessionFired := false;
  Self.OnInboundCallFired  := false;
  Self.Password            := 'mycotoxin';
  Self.TryAgain            := true;
  Self.SessionEstablished  := false;

  Self.Locator.AddA(Self.Core.From.Address.Host, '127.0.0.1');
end;

procedure TestTIdSipUserAgent.TearDown;
begin
  Self.SendEvent.Free;
  Self.Dlg.Free;
  Self.RouteSet.Free;
  Self.RemoteUri.Free;
  Self.RemoteTarget.Free;
  Self.LocalUri.Free;
  Self.ID.Free;
  Self.OnChangedEvent.Free;

  inherited TearDown;
end;

//* TestTIdSipUserAgent Private methods ****************************************

procedure TestTIdSipUserAgent.CheckCommaSeparatedHeaders(const ExpectedValues: String;
                                                         Header: TIdSipHeader;
                                                         const Msg: String);
var
  Hdr:    TIdSipCommaSeparatedHeader;
  I:      Integer;
  Values: TStringList;
begin
  CheckEquals(TIdSipCommaSeparatedHeader.ClassName,
              Header.ClassName,
              Msg + ': Unexpected header type in CheckCommaSeparatedHeaders');

  Hdr := Header as TIdSipCommaSeparatedHeader;
  Values := TStringList.Create;
  try
    Values.CommaText := ExpectedValues;

    for I := 0 to Values.Count - 1 do
      CheckEquals(Values[I],
                  Hdr.Values[I],
                  Msg + ': ' + IntToStr(I + 1) + 'th value');
  finally
    Values.Free;
  end;
end;

procedure TestTIdSipUserAgent.CheckCreateRequest(Dest: TIdSipToHeader;
                                                 Request: TIdSipRequest);
var
  Contact: TIdSipContactHeader;
begin
  CheckEquals(Dest.Address,
              Request.RequestUri,
              'Request-URI not properly set');

  Check(Request.HasHeader(CallIDHeaderFull), 'No Call-ID header added');
  CheckNotEquals('',
                 (Request.FirstHeader(CallIDHeaderFull) as TIdSipCallIdHeader).Value,
                 'Call-ID must not be empty');

  Check(Request.HasHeader(ContactHeaderFull), 'No Contact header added');
  Contact := Request.FirstContact;
  Check(Contact.Equals(Self.Core.Contact), 'Contact header incorrectly set');

  CheckEquals(Request.From.DisplayName,
              Self.Core.From.DisplayName,
              'From.DisplayName');
  CheckEquals(Request.From.Address,
              Self.Core.From.Address,
              'From.Address');
    Check(Request.From.HasTag,
          'Requests MUST have a From tag; cf. RFC 3261 section 8.1.1.3');

  CheckEquals(Request.RequestUri,
              Request.ToHeader.Address,
              'To header incorrectly set');

  CheckEquals(1,
              Request.Path.Length,
              'New requests MUST have a Via header; cf. RFC 3261 section 8.1.1.7');
  Check(Request.LastHop.HasBranch,
        'New requests MUST have a branch; cf. RFC 3261 section 8.1.1.7');
  CheckEquals(UdpTransport,
              Request.LastHop.Transport,
              'UDP should be the default transport');
end;

procedure TestTIdSipUserAgent.OnAuthenticationChallenge(Action: TIdSipAction;
                                                        Response: TIdSipResponse);
begin
  raise Exception.Create('implement TestTIdSipUserAgent.OnAuthenticationChallenge');
end;

procedure TestTIdSipUserAgent.OnAuthenticationChallenge(UserAgent: TIdSipAbstractUserAgent;
                                                        Challenge: TIdSipResponse;
                                                        var Username: String;
                                                        var Password: String;
                                                        var TryAgain: Boolean);
begin
  Password := Self.Password;
  TryAgain := Self.TryAgain;
  Username := Self.Core.Username;
end;

procedure TestTIdSipUserAgent.OnChanged(Observed: TObject);
begin
  Self.OnChangedEvent.SetEvent;
end;

procedure TestTIdSipUserAgent.OnDroppedUnmatchedMessage(UserAgent: TIdSipAbstractUserAgent;
                                                        Message: TIdSipMessage;
                                                        Receiver: TIdSipTransport);
begin
end;

procedure TestTIdSipUserAgent.OnEndedSession(Session: TIdSipSession;
                                             ErrorCode: Cardinal;
                                             const Reason: String);
begin
  Self.OnEndedSessionFired := true;
  Self.ThreadEvent.SetEvent;
end;

procedure TestTIdSipUserAgent.OnEstablishedSession(Session: TIdSipSession;
                                                   const RemoteSessionDescription: String;
                                                   const MimeType: String);
begin
  Self.InboundCallMimeType := MimeType;
  Self.InboundCallOffer    := RemoteSessionDescription;
  Self.SessionEstablished  := true;
end;

procedure TestTIdSipUserAgent.OnInboundCall(UserAgent: TIdSipUserAgent;
                                            Session: TIdSipInboundSession);
begin
  Self.InboundCallMimeType := Session.RemoteMimeType;
  Self.InboundCallOffer    := Session.RemoteSessionDescription;
  Self.UserAgentParam      := UserAgent;
  Self.OnInboundCallFired := true;

  Session.AddSessionListener(Self);
  Self.Session := Session;
  Self.ThreadEvent.SetEvent;
end;

procedure TestTIdSipUserAgent.OnModifiedSession(Session: TIdSipSession;
                                                Answer: TIdSipResponse);
begin
end;

procedure TestTIdSipUserAgent.OnModifySession(Session: TIdSipSession;
                                              const RemoteSessionDescription: String;
                                              const MimeType: String);
begin
end;

procedure TestTIdSipUserAgent.OnNetworkFailure(Action: TIdSipAction;
                                               ErrorCode: Cardinal;
                                               const Reason: String);
begin
  Self.FailReason := Reason;
end;

procedure TestTIdSipUserAgent.OnProgressedSession(Session: TIdSipSession;
                                                  Progress: TIdSipResponse);
begin
end;

procedure TestTIdSipUserAgent.OnSendRequest(Request: TIdSipRequest;
                                            Sender: TIdSipTransport);
begin
end;

procedure TestTIdSipUserAgent.OnSendResponse(Response: TIdSipResponse;
                                             Sender: TIdSipTransport);
begin
  if (Response.StatusCode = SIPSessionProgress) then
    Self.SendEvent.SetEvent;
end;

procedure TestTIdSipUserAgent.ReceiveBye(Dialog: TIdSipDialog);
var
  Bye: TIdSipRequest;
begin
  Bye := Self.CreateRemoteBye(Dialog);
  try
    Self.ReceiveRequest(Bye);
  finally
    Bye.Free;
  end;
end;

//* TestTIdSipUserAgent Published methods **************************************

procedure TestTIdSipUserAgent.TestAcksDontMakeTransactions;
var
  Ack:       TIdSipRequest;
  RemoteDlg: TIdSipDialog;
  TranCount: Cardinal;
begin
  Self.ReceiveInvite;

  Check(Assigned(Self.Session), 'TU not informed of inbound call');
  Self.Session.AcceptCall('', '');

  TranCount := Self.Dispatcher.TransactionCount;

  RemoteDlg := TIdSipDialog.CreateOutboundDialog(Self.LastSentRequest,
                                                 Self.LastSentResponse,
                                                 false);
  try
    Ack := RemoteDlg.CreateAck;
    try
      Self.ReceiveRequest(Ack);

      CheckEquals(TranCount,
                Self.Dispatcher.TransactionCount,
                  'A transaction got made in response to an ACK');
      CheckEquals(1,
                  Self.Core.SessionCount,
                  'ACK wasn''t simply dropped by the TU');
    finally
      Ack.Free;
    end;
  finally
    RemoteDlg.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestAcceptCallSchedulesResendOk;
begin
  Self.ReceiveInvite;
  Check(Assigned(Self.Session), 'TU not informed of inbound call');
  Self.MarkSentResponseCount;
  
  Self.Session.AcceptCall('', '');
  Self.DebugTimer.TriggerEarliestEvent;
  CheckResponseSent('No OK sent');
  CheckEquals(SIPOK, Self.LastSentResponse.StatusCode, 'Unexpected response sent');

  Self.MarkSentResponseCount;
  Self.DebugTimer.TriggerEarliestEvent;
  CheckResponseSent('No OK resent');
  CheckEquals(SIPOK, Self.LastSentResponse.StatusCode, 'Unexpected response resent');
end;

procedure TestTIdSipUserAgent.TestActionsNotifyUAObservers;
var
  L1: TIdObserverListener;
begin
  L1 := TIdObserverListener.Create;
  try
    Self.Core.AddObserver(L1);

    Self.ReceiveInvite;

    Check(L1.Changed, 'L1 not notified');
  finally
    Self.Core.RemoveObserver(L1);
    L1.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestAddAllowedContentType;
var
  ContentTypes: TStrings;
begin
  ContentTypes := TStringList.Create;
  try
    Self.Core.AddAllowedContentType(SdpMimeType);
    Self.Core.AddAllowedContentType(PlainTextMimeType);

    ContentTypes.CommaText := Self.Core.AllowedContentTypes;

    CheckEquals(2, ContentTypes.Count, 'Number of allowed Content-Types');

    CheckEquals(SdpMimeType,       ContentTypes[0], SdpMimeType);
    CheckEquals(PlainTextMimeType, ContentTypes[1], PlainTextMimeType);
  finally
    ContentTypes.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestAddAllowedContentTypeMalformed;
var
  ContentTypes: String;
begin
  ContentTypes := Self.Core.AllowedContentTypes;
  Self.Core.AddAllowedContentType(' ');
  CheckEquals(ContentTypes,
              Self.Core.AllowedContentTypes,
              'Malformed Content-Type was allowed');
end;

procedure TestTIdSipUserAgent.TestAddAllowedLanguage;
var
  Languages: TStrings;
begin
  Languages := TStringList.Create;
  try
    Self.Core.AddAllowedLanguage('en');
    Self.Core.AddAllowedLanguage('af');

    Languages.CommaText := Self.Core.AllowedLanguages;

    CheckEquals(2, Languages.Count, 'Number of allowed Languages');

    CheckEquals('en', Languages[0], 'en first');
    CheckEquals('af', Languages[1], 'af second');
  finally
    Languages.Free;
  end;

  try
    Self.Core.AddAllowedLanguage(' ');
    Fail('Failed to forbid adding a malformed language ID');
  except
    on EIdException do;
  end;
end;

procedure TestTIdSipUserAgent.TestAddAllowedLanguageLanguageAlreadyPresent;
var
  Languages: TStrings;
begin
  Languages := TStringList.Create;
  try
    Self.Core.AddAllowedLanguage('en');
    Self.Core.AddAllowedLanguage('en');

    Languages.CommaText := Self.Core.AllowedLanguages;

    CheckEquals(1, Languages.Count, 'en was re-added');
  finally
    Languages.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestAddAllowedMethod;
var
  Methods: TStringList;
begin
  Methods := TStringList.Create;
  try
    Methods.CommaText := Self.Core.KnownMethods;
    Methods.Sort;

    CheckEquals(MethodAck,     Methods[0], 'ACK first');
    CheckEquals(MethodBye,     Methods[1], 'BYE second');
    CheckEquals(MethodCancel,  Methods[2], 'CANCEL third');
    CheckEquals(MethodInvite,  Methods[3], 'INVITE fourth');
    CheckEquals(MethodOptions, Methods[4], 'OPTIONS fifth');

    CheckEquals(5, Methods.Count, 'Number of allowed methods');
  finally
    Methods.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestAddAllowedMethodMethodAlreadyPresent;
var
  Methods: TStrings;
  MethodCount: Cardinal;
begin
  Methods := TStringList.Create;
  try
    Self.Core.AddModule(TIdSipInviteModule);
    Methods.CommaText := Self.Core.KnownMethods;
    MethodCount := Methods.Count;

    Self.Core.AddModule(TIdSipInviteModule);
    Methods.CommaText := Self.Core.KnownMethods;

    CheckEquals(MethodCount, Methods.Count, MethodInvite + ' was re-added');
  finally
    Methods.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestAddAllowedScheme;
var
  Schemes: TStrings;
begin
  Schemes := TStringList.Create;
  try
    Self.Core.AddAllowedScheme(SipScheme);
    Self.Core.AddAllowedScheme(SipsScheme);

    Schemes.CommaText := Self.Core.AllowedSchemes;

    CheckEquals(2, Schemes.Count, 'Number of allowed Schemes');

    CheckEquals(SipScheme,  Schemes[0], 'SIP first');
    CheckEquals(SipsScheme, Schemes[1], 'SIPS second');
  finally
    Schemes.Free;
  end;

  try
    Self.Core.AddAllowedScheme(' ');
    Fail('Failed to forbid adding a malformed URI scheme');
  except
    on EIdException do;
  end;
end;

procedure TestTIdSipUserAgent.TestAddAllowedSchemeSchemeAlreadyPresent;
var
  Schemes: TStrings;
begin
  Schemes := TStringList.Create;
  try
    Self.Core.AddAllowedScheme(SipScheme);

    Schemes.CommaText := Self.Core.AllowedSchemes;

    CheckEquals(1, Schemes.Count, 'SipScheme was re-added');
  finally
    Schemes.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestAddModule;
var
  Module:     TIdSipMessageModule;
  ModuleType: TIdSipMessageModuleClass;
begin
  ModuleType := TIdSipSubscribeModule;

  Module := Self.Core.AddModule(ModuleType);
  Check(Assigned(Module),
        'AddModule didn''t return anything');
  CheckEquals(ModuleType.ClassName,
              Module.ClassName,
              'AddModule returned an unexpected module');

  Module := Self.Core.AddModule(ModuleType);
  Check(Assigned(Module),
        'AddModule didn''t return anything for an already-installed module');
end;

procedure TestTIdSipUserAgent.TestAddObserver;
var
  L1, L2: TIdObserverListener;
begin
  L1 := TIdObserverListener.Create;
  try
    L2 := TIdObserverListener.Create;
    try
      Self.Core.AddObserver(L1);
      Self.Core.AddObserver(L2);

      Self.ReceiveInvite;

      Check(L1.Changed and L2.Changed, 'Not all Listeners notified, hence not added');
    finally
      L2.Free;
    end;
  finally
    L1.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestAddUserAgentListener;
var
  L1, L2: TIdSipTestUserAgentListener;
begin
  L1 := TIdSipTestUserAgentListener.Create;
  try
    L2 := TIdSipTestUserAgentListener.Create;
    try
      Self.Core.AddUserAgentListener(L1);
      Self.Core.AddUserAgentListener(L2);

      Self.ReceiveInvite;

      Check(L1.InboundCall and L2.InboundCall,
            'Not all Listeners notified, hence not added');
    finally
      L2.Free;
    end;
  finally
    L1.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestByeWithAuthentication;
var
  Session: TIdSipOutboundSession;
begin
  //  ---      INVITE      --->
  // <---      200 OK      --->
  //  ---        ACK       --->
  // ==========================
  //       Media streams
  // ==========================
  //  ---        BYE       --->
  // <--- 401 Unauthorized ---
  //  ---        BYE       --->
  // <---      200 OK      --->

  Session := Self.Core.InviteModule.Call(Self.Destination, '', '');
  Session.AddSessionListener(Self);
  Session.Send;

  Self.MarkSentAckCount;
  Self.ReceiveOk(Self.LastSentRequest);
  CheckAckSent('No ACK sent: ' + Self.FailReason);

  Session.Terminate;

  // This is a bit tricky - the Transaction layer reissues the request, not the
  // Transaction-User layer. All the TU layer does is provide an authentication
  // token.
  Self.MarkSentRequestCount;
  Self.ReceiveUnauthorized(WWWAuthenticateHeader, '');
  Self.CheckRequestSent('No re-issue of a BYE');
end;

procedure TestTIdSipUserAgent.TestCallUsingProxy;
const
  ProxyUri = 'sip:proxy.tessier-ashpool.co.luna';
var
  Invite: TIdSipRequest;
begin
  Self.Core.Proxy.Uri := ProxyUri;
  Self.Core.HasProxy := true;

  Self.MarkSentRequestCount;
  Self.Core.InviteModule.Call(Self.Destination, '', '').Send;
  CheckRequestSent('No request sent');
  CheckEquals(MethodInvite,
              Self.LastSentRequest.Method,
              'Unexpected request sent');

  Invite := Self.LastSentRequest;
  Check(Invite.HasHeader(RouteHeader),
        'No Route header added');

  Invite.Route.First;
  CheckEquals(ProxyUri,
              Invite.Route.CurrentRoute.Address.Uri,
              'Route points to wrong proxy');
end;

procedure TestTIdSipUserAgent.TestCancelNotifiesTU;
var
  SessCount: Integer;
begin
  Self.ReceiveInvite;
  SessCount := Self.Core.SessionCount;
  Self.ReceiveCancel;

  Check(Self.OnEndedSessionFired,
        'UA not notified of remote CANCEL');
  Check(Self.Core.SessionCount < SessCount,
        'UA didn''t remove cancelled session');
end;

procedure TestTIdSipUserAgent.TestConcurrentCalls;
var
  AckOne:    TIdSipRequest;
  AckTwo:    TIdSipRequest;
  ByeOne:    TIdSipRequest;
  ByeTwo:    TIdSipRequest;
  DialogOne: TIdSipDialog;
  DialogTwo: TIdSipDialog;
  InviteOne: TIdSipRequest;
  InviteTwo: TIdSipRequest;
begin
  // <---    INVITE #1   ---
  //  ---     100 #1     --->
  //  ---     180 #1     --->
  //  ---     200 #1     --->
  // <---     ACK #1     ---
  //  ---   200 #1 (ACK) --->
  // <---    INVITE #2   ---
  //  ---     100 #2     --->
  //  ---     180 #2     --->
  //  ---     200 #2     --->
  // <---     ACK #2     ---
  //  ---   200 #2 (ACK) --->
  // <---     BYE #1     ---
  //  ---   200 #1 (BYE) --->
  // <---     BYE #2     ---
  //  ---   200 #2 (BYE) --->

  Self.Dispatcher.Transport.WriteLog := true;

  InviteOne := TIdSipTestResources.CreateBasicRequest;
  try
    InviteTwo := TIdSipTestResources.CreateBasicRequest;
    try
      InviteOne.CallID         := '1.' + InviteOne.CallID;
      InviteOne.From.Tag       := '1';
      InviteOne.LastHop.Branch := InviteOne.LastHop.Branch + '1';
      InviteTwo.CallID         := '2.' + InviteTwo.CallID;
      InviteTwo.From.Tag       := '2';
      InviteTwo.LastHop.Branch := InviteTwo.LastHop.Branch + '2';

      Self.ReceiveRequest(InviteOne);
      Check(Self.OnInboundCallFired, 'OnInboundCall didn''t fire for 1st INVITE');
      Self.Session.AcceptCall('', '');

      // DialogOne represents the remote agent's dialog for the 1st INVITE.
      DialogOne := TIdSipDialog.CreateInboundDialog(InviteOne,
                                                    Self.LastSentResponse,
                                                    InviteOne.RequestUri.IsSecure);
      try
        AckOne := DialogOne.CreateAck;
        try
          Self.ReceiveRequest(AckOne);
        finally
          AckOne.Free;
        end;

        Self.OnInboundCallFired := false;
        Self.ReceiveRequest(InviteTwo);
        Check(Self.OnInboundCallFired, 'OnInboundCall didn''t fire for 2nd INVITE');
        Self.Session.AcceptCall('', '');

        // DialogTwo represents the remote agent's dialog for the 2nd INVITE.
        DialogTwo := TIdSipDialog.CreateInboundDialog(InviteTwo,
                                                      Self.LastSentResponse,
                                                      InviteTwo.RequestUri.IsSecure);
        try
          AckTwo := DialogTwo.CreateAck;
          try
            Self.ReceiveRequest(AckTwo);
          finally
            AckTwo.Free;
          end;

          Self.MarkSentResponseCount;
          ByeOne := DialogOne.CreateRequest;
          try
            Self.ReceiveBye(DialogOne);
          finally
            ByeOne.Free;
          end;

          CheckResponseSent('No response sent for the 1st INVITE''s BYE');
          CheckEquals(SIPOK,
                      Self.LastSentResponse.StatusCode,
                      'Unexpected response for the 1st INVITE''s BYE');

          Self.MarkSentResponseCount;
          ByeTwo := DialogTwo.CreateRequest;
          try
            Self.ReceiveBye(DialogTwo);
          finally
            ByeTwo.Free;
          end;

          CheckResponseSent('No response sent for the 2nd INVITE''s BYE');
          CheckEquals(SIPOK,
                      Self.LastSentResponse.StatusCode,
                      'Unexpected response for the 2nd INVITE''s BYE');
        finally
          DialogTwo.Free;
        end;
      finally
        DialogOne.Free;
      end;
    finally
      InviteTwo.Free;
    end;
  finally
    InviteOne.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestContentTypeDefault;
begin
  CheckEquals(SdpMimeType,
              Self.Core.AllowedContentTypes,
              'AllowedContentTypes');
end;

procedure TestTIdSipUserAgent.TestCreateOptions;
var
  Options: TIdSipRequest;
begin
  Options := Self.Core.CreateOptions(Self.Destination);
  try
    CheckEquals(MethodOptions, Options.Method,      'Incorrect method');
    CheckEquals(MethodOptions, Options.CSeq.Method, 'Incorrect CSeq method');
    Check(Options.HasHeader(AcceptHeader),          'Missing Accept header');
    CheckEquals(Self.Core.AllowedContentTypes,
                Options.FirstHeader(AcceptHeader).Value,
                'Accept value');
  finally
    Options.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestCreateRequest;
const
  UnknownMethod = 'Foo';
var
  Request: TIdSipRequest;
  Dest:    TIdSipToHeader;
begin
  Dest := TIdSipToHeader.Create;
  try
    Dest.Address.URI := 'sip:wintermute@tessier-ashpool.co.luna';
    Request := Self.Core.CreateRequest(UnknownMethod, Dest);
    try
      CheckEquals(UnknownMethod, Request.Method, 'Requet-Method');
      Self.CheckCreateRequest(Dest, Request);
    finally
      Request.Free;
    end;
  finally
    Dest.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestCreateRequestSipsRequestUri;
var
  Contact: TIdSipContactHeader;
  Request: TIdSipRequest;
  Dest:    TIdSipToHeader;
begin
  Dest := TIdSipToHeader.Create;
  try
    Dest.Address.URI := 'sips:wintermute@tessier-ashpool.co.luna';
    Request := Self.Core.CreateRequest(MethodInvite, Dest);
    try
      Contact := Request.FirstContact;
      CheckEquals(SipsScheme,
                  Contact.Address.Scheme,
                  'Contact doesn''t have a SIPS URI');
    finally
      Request.Free;
    end;
  finally
    Dest.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestCreateRequestUserAgent;
var
  Request: TIdSipRequest;
  Dest:    TIdSipToHeader;
begin
  Self.Core.UserAgentName := 'SATAN/1.0';

  Dest := TIdSipToHeader.Create;
  try
    Dest.Address.URI := 'sip:wintermute@tessier-ashpool.co.luna';
    Request := Self.Core.CreateRequest(MethodInvite, Dest);
    try
      CheckEquals(Self.Core.UserAgentName,
                  Request.FirstHeader(UserAgentHeader).Value,
                  'User-Agent header not set');
    finally
      Request.Free;
    end;
  finally
    Dest.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestCreateRequestWithTransport;
var
  Request: TIdSipRequest;
  Dest:    TIdSipToHeader;
begin
  Dest := TIdSipToHeader.Create;
  try
    Dest.Address.URI := 'sip:wintermute@tessier-ashpool.co.luna;transport=udp';
    Request := Self.Core.CreateRequest(MethodInvite, Dest);
    try
      CheckEquals(UdpTransport,
                  Request.LastHop.Transport,
                  'UDP transport not specified');
    finally
      Request.Free;
    end;

    Dest.Address.URI := 'sip:wintermute@tessier-ashpool.co.luna;transport=tcp';
    Request := Self.Core.CreateRequest(MethodInvite, Dest);
    try
      CheckEquals(TcpTransport,
                  Request.LastHop.Transport,
                  'TCP transport not specified');
    finally
      Request.Free;
    end;

    Dest.Address.URI := 'sip:wintermute@tessier-ashpool.co.luna;transport=foo';
    Request := Self.Core.CreateRequest(MethodInvite, Dest);
    try
      CheckEquals('FOO',
                  Request.LastHop.Transport,
                  'foo transport not specified');
    finally
      Request.Free;
    end;
  finally
    Dest.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestCreateResponseToTagMissing;
var
  Response: TIdSipResponse;
begin
  // This culls the parameters
  Self.Invite.ToHeader.Value := Self.Invite.ToHeader.Value;

  Response := Self.Core.CreateResponse(Self.Invite, SIPOK);
  try
    Check(Response.ToHeader.HasTag,
          'To is missing a tag');

    CheckEquals(Response.ToHeader.Address,
                Self.Invite.ToHeader.Address,
                'To header address mismatch');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestCreateResponseUserAgent;
var
  Response: TIdSipResponse;
begin
  Self.Core.UserAgentName := 'SATAN/1.0';
  Self.Invite.RequestUri.URI := 'sip:wintermute@tessier-ashpool.co.luna';

  Response := Self.Core.CreateResponse(Self.Invite, SIPOK);
  try
    CheckEquals(Self.Core.UserAgentName,
                Response.FirstHeader(ServerHeader).Value,
                'User-Agent header not set');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestCreateResponseUserAgentBlank;
var
  Response: TIdSipResponse;
begin
  Self.Core.UserAgentName := '';
  Self.Invite.RequestUri.URI := 'sip:wintermute@tessier-ashpool.co.luna';

  Response := Self.Core.CreateResponse(Self.Invite, SIPOK);
  try
    Check(not Response.HasHeader(UserAgentHeader),
          'User-Agent header not removed because it''s blank');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestDeclinedCallNotifiesListeners;
var
  O: TIdObserverListener;
begin
  Self.Core.InviteModule.Call(Self.Destination, '', '').Send;

  O := TIdObserverListener.Create;
  try
    Self.Core.AddObserver(O);

    Self.ReceiveResponse(SIPDecline);

    Check(O.Changed, 'Clearing up a terminated action should notify observers');
  finally
    Self.Core.RemoveObserver(O);
    O.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestDestroyCallsModuleCleanups;
var
  Registrar: TIdSipMockUdpTransport;
  UA:        TIdSipUserAgent;
begin
  Registrar := TIdSipMockUdpTransport.Create;
  try
    Registrar.Address  := '127.0.0.1';
    Registrar.HostName := '127.0.0.1';
    Registrar.Port     := 25060;

    UA := Self.CreateUserAgent;
    try
      UA.RegisterModule.Registrar.Uri := 'sip:' + Registrar.Address + ':' + IntToStr(Registrar.Port);
      UA.RegisterModule.HasRegistrar  := true;
    finally
      UA.Free;
    end;

    Check(Registrar.LastRequest <> nil,
          'No REGISTER sent, so Module.Cleanup not called');
  finally
    Registrar.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestDialogLocalSequenceNoMonotonicallyIncreases;
var
  BaseSeqNo: Cardinal;
  R:         TIdSipRequest;
begin
  R := Self.Core.CreateRequest(MethodInvite, Self.Dlg);
  try
     BaseSeqNo := R.CSeq.SequenceNo;
  finally
    R.Free;
  end;

  R := Self.Core.CreateRequest(MethodInvite, Self.Dlg);
  try
    CheckEquals(BaseSeqNo + 1,
                R.CSeq.SequenceNo,
                'Not monotonically increasing by one');
  finally
    R.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestDispatchToCorrectSession;
var
  SessionOne: TIdSipInboundSession;
  SessionTwo: TIdSipInboundSession;
begin
  // 1. Receive two inbound sessions.
  // 2. Receive a BYE for one of them.
  // 3. Check that the correct session died, and the other didn't.

  Self.ReceiveInvite;
  Check(Assigned(Self.Session),
        'OnInboundCall didn''t fire');
  SessionOne := Self.Session;

  Self.Invite.LastHop.Branch := Self.Invite.LastHop.Branch + '1';
  Self.Invite.From.Tag       := Self.Invite.From.Tag + '1';
  Self.Invite.ToHeader.Tag   := Self.Invite.ToHeader.Tag + '1';
  Self.ReceiveInvite;
  Check(Self.Session <> SessionOne,
        'OnInboundCall didn''t fire a second time');
  SessionTwo := Self.Session;
  CheckEquals(2,
              Self.Core.SessionCount,
              'Number of sessions after two INVITEs');


  SessionTwo.AcceptCall('', '');
  Check(SessionTwo.DialogEstablished, 'SessionTwo''s dialog wasn''t established');

  SessionTwo.AddSessionListener(Self);
  Self.ThreadEvent.ResetEvent;
  Self.ExceptionMessage := 'SessionTwo wasn''t terminated';
  Self.ReceiveBye(SessionTwo.Dialog);

  Check(not SessionOne.IsTerminated, 'SessionOne was terminated');
  CheckEquals(1,
              Self.Core.SessionCount,
              'Number of sessions after one BYE');
end;

procedure TestTIdSipUserAgent.TestDoNotDisturb;
var
  SessionCount: Cardinal;
begin
  Self.Core.DoNotDisturb := true;
  Self.MarkSentResponseCount;
  SessionCount  := Self.Core.SessionCount;

  Self.ReceiveInvite;
  CheckResponseSent('No response sent when UA set to Do Not Disturb');

  CheckEquals(SIPTemporarilyUnavailable,
              Self.LastSentResponse.StatusCode,
              'Wrong response sent');
  CheckEquals(Self.Core.DoNotDisturbMessage,
              Self.LastSentResponse.StatusText,
              'Wrong status text');
  CheckEquals(SessionCount,
              Self.Core.SessionCount,
              'New session created despite Do Not Disturb');
end;

procedure TestTIdSipUserAgent.TestDontReAuthenticate;
begin
  Self.TryAgain := false;

  Self.Core.InviteModule.Call(Self.Destination, '', '').Send;

  Self.MarkSentRequestCount;
  Self.ReceiveUnauthorized(ProxyAuthenticateHeader, QopAuthInt);

  CheckNoRequestSent('Reattempted authentication');
end;

procedure TestTIdSipUserAgent.TestHasUnknownAccept;
begin
  Self.Invite.RemoveHeader(Self.Invite.FirstHeader(AcceptHeader));

  Check(not Self.Core.HasUnknownAccept(Self.Invite),
        'Vacuously true');

  Self.Invite.AddHeader(AcceptHeader).Value := SdpMimeType;
  Check(not Self.Core.HasUnknownAccept(Self.Invite),
        SdpMimeType + ' MUST supported');

  Self.Invite.RemoveHeader(Self.Invite.FirstHeader(AcceptHeader));
  Self.Invite.AddHeader(AcceptHeader);
  Check(Self.Core.HasUnknownAccept(Self.Invite),
        'Nothing else is supported');
end;

procedure TestTIdSipUserAgent.TestHasUnknownContentEncoding;
begin
  Self.Invite.Headers.Remove(Self.Invite.FirstHeader(ContentEncodingHeaderFull));

  Check(not Self.Core.HasUnknownContentEncoding(Self.Invite),
        'Vacuously true');

  Self.Invite.AddHeader(ContentEncodingHeaderFull);
  Check(Self.Core.HasUnknownContentEncoding(Self.Invite),
        'No encodings are supported');
end;

procedure TestTIdSipUserAgent.TestHasUnknownContentType;
begin
  Self.Invite.RemoveHeader(Self.Invite.FirstHeader(ContentTypeHeaderFull));

  Check(not Self.Core.HasUnknownContentType(Self.Invite),
        'Vacuously true');

  Self.Invite.AddHeader(ContentTypeHeaderFull).Value := SdpMimeType;
  Check(not Self.Core.HasUnknownContentType(Self.Invite),
        SdpMimeType + ' MUST supported');

  Self.Invite.RemoveHeader(Self.Invite.FirstHeader(ContentTypeHeaderFull));
  Self.Invite.AddHeader(ContentTypeHeaderFull);
  Check(Self.Core.HasUnknownContentType(Self.Invite),
        'Nothing else is supported');
end;

procedure TestTIdSipUserAgent.TestInboundCall;
begin
  Self.Invite.Body          := TIdSipTestResources.BasicSDP('foo.com');
  Self.Invite.ContentLength := Length(Self.Invite.Body);
  Self.Invite.ContentType   := SdpMimeType;

  Self.ReceiveInvite;

  Check(Assigned(Self.UserAgentParam),
        'OnInboundCall didn''t fire');

  CheckEquals(Self.Invite.Body,
              Self.InboundCallOffer,
              'Offer');
  CheckEquals(Self.Invite.ContentType,
              Self.InboundCallMimeType,
              'Offer MIME type');
  Check(Self.Core = Self.UserAgentParam,
        'UserAgent param of Session''s InboundCall notification wrong');
end;

procedure TestTIdSipUserAgent.TestInviteExpires;
begin
  Self.Core.AddObserver(Self);

  Self.MarkSentResponseCount;

  Self.Invite.FirstExpires.NumericValue := 50;
  Self.ReceiveInvite;

  Check(Assigned(Self.Session), 'OnInboundCall didn''t fire');

  Self.DebugTimer.TriggerEarliestEvent;

  CheckResponseSent('No response sent');
  CheckEquals(SIPRequestTerminated,
              Self.LastSentResponse.StatusCode,
              'Unexpected response sent');

  CheckEquals(0, Self.Core.SessionCount, 'Expired session not cleaned up');
end;

procedure TestTIdSipUserAgent.TestInviteRaceCondition;
begin
  CheckEquals(0,
              Self.Core.CountOf(MethodInvite),
              'Sanity check - new test should have no ongoing INVITE actions');

  Self.MarkSentResponseCount;
  Self.ReceiveInvite;
  CheckEquals(1,
              Self.Core.CountOf(MethodInvite),
              'First INVITE didn''t make a new INVITE action');

  CheckResponseSent('No response sent');

  Self.ReceiveInvite;
  CheckEquals(1,
              Self.Core.CountOf(MethodInvite),
              'INVITE resend made a new INVITE action');
end;

procedure TestTIdSipUserAgent.TestIsMethodSupported;
begin
  Check(not Self.Core.IsMethodSupported(MethodRegister),
        MethodRegister + ' not allowed');

  Self.Core.AddModule(TIdSipRegisterModule);
  Check(Self.Core.IsMethodSupported(MethodRegister),
        MethodRegister + ' not recognised as an allowed method');

  Check(not Self.Core.IsMethodSupported(' '),
        ''' '' recognised as an allowed method');
end;

procedure TestTIdSipUserAgent.TestIsSchemeAllowed;
begin
  Check(not Self.Core.IsMethodSupported(SipScheme),
        SipScheme + ' not allowed');

  Self.Core.AddAllowedScheme(SipScheme);
  Check(Self.Core.IsSchemeAllowed(SipScheme),
        SipScheme + ' not recognised as an allowed scheme');

  Check(not Self.Core.IsSchemeAllowed(' '),
        ''' '' not recognised as an allowed scheme');
end;

procedure TestTIdSipUserAgent.TestLoopDetection;
var
  Response: TIdSipResponse;
begin
  // cf. RFC 3261, section 8.2.2.2
  Self.Dispatcher.AddServerTransaction(Self.Invite, Self.Dispatcher.Transport);

  // wipe out the tag & give a different branch
  Self.Invite.ToHeader.Value := Self.Invite.ToHeader.Address.URI;
  Self.Invite.LastHop.Branch := Self.Invite.LastHop.Branch + '1';

  Self.MarkSentResponseCount;

  Self.ReceiveInvite;
  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPLoopDetected, Response.StatusCode, 'Status-Code');
end;

procedure TestTIdSipUserAgent.TestMergedRequest;
var
  FirstInvite:  TIdSipRequest;
  SecondInvite: TIdSipRequest;
begin
  FirstInvite := TIdSipRequest.ReadRequestFrom(SFTFInvite);
  try
    SecondInvite := TIdSipRequest.ReadRequestFrom(SFTFMergedInvite);
    try
      Self.ReceiveRequest(FirstInvite);
      Self.MarkSentResponseCount;
      Self.ReceiveRequest(SecondInvite);

      CheckResponseSent('No response sent');

      Check(SecondInvite.Match(Self.LastSentResponse),
            'Response not for 2nd INVITE');
      CheckEquals(SIPLoopDetected,
                  Self.LastSentResponse.StatusCode,
                  'Unexpected response');
    finally
      SecondInvite.Free;
    end;
  finally
    FirstInvite.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestModuleForString;
begin
  CheckNull(Self.Core.ModuleFor(''),
            'Empty string');
  CheckNull(Self.Core.ModuleFor(MethodRegister),
            MethodRegister + ' but no module added');

  Self.Core.AddModule(TIdSipRegisterModule);
  CheckNotNull(Self.Core.ModuleFor(MethodRegister),
               MethodRegister + ' but no module added');
  CheckEquals(TIdSipRegisterModule.ClassName,
              Self.Core.ModuleFor(MethodRegister).ClassName,
              MethodRegister + ' after module added: wrong type');
  CheckNull(Self.Core.ModuleFor(Lowercase(MethodRegister)),
            Lowercase(MethodRegister)
          + ': RFC 3261 defines REGISTER''s method as "REGISTER"');
end;

procedure TestTIdSipUserAgent.TestNextCallID;
var
  CallID: String;
begin
  CallID := Self.Core.NextCallID;

  Fetch(CallID, '@');

  CheckEquals(Self.Core.HostName, CallID, 'HostName not used');
end;

procedure TestTIdSipUserAgent.TestNextTag;
var
  I:    Integer;
  Tags: TStringList;
begin
  // This is a woefully inadequate test. cf. RFC 3261, section 19.3

  Tags := TStringList.Create;
  try
    for I := 1 to 100 do
      Tags.Add(Self.Core.NextTag);

    // Find duplicates
    Tags.Sort;
    CheckNotEquals('', Tags[0], 'No null tags may be generated');

    for I := 1 to Tags.Count - 1 do begin
      CheckNotEquals('', Tags[I], 'No null tags may be generated (Tag #'
                                + IntToStr(I) + ')');

      CheckNotEquals(Tags[I-1], Tags[I], 'Duplicate tag generated');
    end;
  finally
  end;
end;

procedure TestTIdSipUserAgent.TestNotificationOfNewSession;
begin
  Self.ReceiveInvite;

  Check(Self.OnInboundCallFired, 'UI not notified of new session');
end;

procedure TestTIdSipUserAgent.TestNotificationOfNewSessionRobust;
var
  L1, L2: TIdSipTestUserAgentListener;
begin
  L1 := TIdSipTestUserAgentListener.Create;
  try
    L2 := TIdSipTestUserAgentListener.Create;
    try
      L1.FailWith := EParserError;

      Self.Core.AddUserAgentListener(L1);
      Self.Core.AddUserAgentListener(L2);

      Self.ReceiveInvite;

      Check(L2.InboundCall, 'L2 not notified');
    finally
      L2.Free;
    end;
  finally
    L1.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestNotifyOfChange;
var
  C: TIdSipCoreWithExposedNotify;
  O: TIdObserverListener;
begin
  C := TIdSipCoreWithExposedNotify.Create;
  try
    O := TIdObserverListener.Create;
    try
      C.AddObserver(O);
      C.TriggerNotify;
      Check(O.Changed,
            'Observer not notified');
      Check(O.Data = C,
           'Core didn''t return itself as parameter in the notify');
    finally
      O.Free;
    end;
  finally
    C.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestOutboundCallAndByeToXlite;
var
  Session: TIdSipSession;
begin
  Session := Self.Core.InviteModule.Call(Self.Destination, '', '');
  Session.AddSessionListener(Self);
  Session.Send;

  Self.ReceiveTrying(Self.LastSentRequest);
  Check(not Session.DialogEstablished,
        Self.LastSentResponse.Description
      + 's don''t make dialogs');

  Self.ReceiveRinging(Self.LastSentRequest);
  Check(Session.DialogEstablished,
        Self.LastSentResponse.Description
      + 's with To tags make dialogs');
  Check(Session.IsEarly,
        Self.LastSentResponse.Description
      + 's make early dialogs');

  Self.MarkSentAckCount;
  Self.ReceiveOk(Self.LastSentRequest);
  CheckAckSent('No ACK sent: ' + Self.FailReason);
  Check(not Session.IsEarly,
        Self.LastSentResponse.Description
      + 's make non-early dialogs');

  Self.ReceiveOk(Self.LastSentRequest);
  Self.ReceiveOk(Self.LastSentRequest);
  Self.ReceiveOk(Self.LastSentRequest);

  Self.Core.TerminateAllCalls;
  CheckEquals(MethodBye,
              Self.LastSentRequest.Method,
              'Must send a BYE to terminate an established session');
end;

procedure TestTIdSipUserAgent.TestOutboundInviteSessionProgressResends;
begin
  Self.MarkSentResponseCount;

  // Receive an INVITE. Ring. Wait.
  Self.Core.ProgressResendInterval := 50;

  Self.ReceiveInvite;
  Check(Assigned(Self.Session), 'OnInboundCall didn''t fire');

  Self.DebugTimer.TriggerEarliestEvent;

  CheckResponseSent('No response sent');
  CheckEquals(SIPSessionProgress,
              Self.LastSentResponse.StatusCode,
              'Wrong response');
end;

procedure TestTIdSipUserAgent.TestOutboundInviteDoesNotTerminateWhenNoResponse;
begin
  Self.Core.InviteModule.Call(Self.Destination, '', '').Send;
  CheckEquals(1, Self.Core.CountOf(MethodInvite), 'Calling makes an INVITE');

  Self.DebugTimer.TriggerEarliestEvent;
  CheckEquals(1,
              Self.Core.CountOf(MethodInvite),
              'If we never get a response then we DO NOT give up');
end;

procedure TestTIdSipUserAgent.TestReceiveByeForUnmatchedDialog;
var
  Bye:      TIdSipRequest;
  Response: TIdSipResponse;
begin
  Bye := Self.Core.CreateRequest(MethodInvite, Self.Destination);
  try
    Bye.Method          := MethodBye;
    Bye.CSeq.SequenceNo := $deadbeef;
    Bye.CSeq.Method     := Bye.Method;

    Self.MarkSentResponseCount;

    Self.ReceiveRequest(Bye);

    CheckResponseSent('No response sent');
    Response := Self.LastSentResponse;
    CheckEquals(SIPCallLegOrTransactionDoesNotExist,
                Response.StatusCode,
                'Response Status-Code')

  finally
    Bye.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestReceiveByeForDialog;
var
  Response: TIdSipResponse;
begin
  Self.ReceiveInvite;

  Check(Assigned(Self.Session), 'OnInboundCall didn''t fire');
  Self.Session.AcceptCall('', '');
  Self.ReceiveAck;

  Self.MarkSentResponseCount;
  Self.ReceiveBye(Self.Session.Dialog);

  CheckResponseSent('SOMETHING should have sent a response');

  Response := Self.LastSentResponse;
  CheckNotEquals(SIPCallLegOrTransactionDoesNotExist,
                 Response.StatusCode,
                 'UA tells us no matching dialog was found');
end;

procedure TestTIdSipUserAgent.TestReceiveByeDestroysTerminatedSession;
var
  O: TIdObserverListener;
begin
  O := TIdObserverListener.Create;
  try
    Self.ReceiveInvite;
    Check(Assigned(Self.Session), 'OnInboundCall didn''t fire');
    Self.Session.AcceptCall('', '');

    Self.Core.AddObserver(O);

    Self.ReceiveBye(Self.Session.Dialog);

    CheckEquals(0, Self.Core.SessionCount, 'Number of sessions after BYE');
    Check(O.Changed, 'Observer not notified after session ended');
  finally
    Self.Core.RemoveObserver(O);
    O.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestReceiveByeWithoutTags;
var
  Bye:      TIdSipRequest;
  Response: TIdSipResponse;
begin
  Bye := Self.Core.CreateRequest(MethodInvite, Self.Destination);
  try
    Bye.Method          := MethodBye;
    Bye.From.Value      := Bye.From.Address.URI;     // strip the tag
    Bye.ToHeader.Value  := Bye.ToHeader.Address.URI; // strip the tag
    Bye.CSeq.SequenceNo := $deadbeef;
    Bye.CSeq.Method     := Bye.Method;

    Self.MarkSentResponseCount;

    Self.ReceiveRequest(Bye);

    CheckResponseSent('No response sent');
    Response := Self.LastSentResponse;
    CheckEquals(SIPCallLegOrTransactionDoesNotExist,
                Response.StatusCode,
                'Response Status-Code')
  finally
    Bye.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestReceiveOptions;
var
  Options:  TIdSipRequest;
  Response: TIdSipResponse;
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

    Self.Locator.AddA(Options.LastHop.SentBy, '127.0.0.1');

    Self.ReceiveRequest(Options);

    Response := Self.LastSentResponse;
    CheckEquals(SIPOK,
                Response.StatusCode,
                'We should accept all OPTIONS');
  finally
    Options.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestReceiveResponseWithMultipleVias;
var
  Response: TIdSipResponse;
begin
  Self.Core.InviteModule.Call(Self.Destination, '', '');

  Response := TIdSipResponse.InResponseTo(Self.Invite,
                                          SIPOK,
                                          Self.Core.Contact);
  try
    Response.AddHeader(Response.Path.LastHop);
    Self.ReceiveResponse(Response);
    Check(not Self.SessionEstablished,
          'Multiple-Via Response not dropped');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestRejectMalformedAuthorizedRequest;
var
  Auth:     TIdSipMockAuthenticator;
  Response: TIdSipResponse;
begin
  Auth := TIdSipMockAuthenticator.Create;
  try
    Self.Core.RequireAuthentication := true;
    Self.Core.Authenticator := Auth;
    Auth.FailWith := EAuthenticate;

    Self.MarkSentResponseCount;

    Self.Invite.AddHeader(AuthorizationHeader);
    Self.ReceiveInvite;
    CheckResponseSent('No response sent');

    Response := Self.LastSentResponse;
    CheckEquals(SIPBadRequest,
                Response.StatusCode,
                'Status code');
  finally
    Auth.Free;
    Self.Core.Authenticator := Self.Authenticator;
  end;
end;

procedure TestTIdSipUserAgent.TestRejectMethodNotAllowed;
//var
//  Response: TIdSipResponse;
begin
  // This blank test serves as a reminder of missing functionality: we want to
  // support permissions on our URIs, so that we can express the fact that we
  // allow someone to subscribe to URI-A's state, but not to URI-B's. 
{
  Self.MarkSentResponseCount;

  Self.ReceiveSubscribe('Foo');

  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPMethodNotAllowed,
              Response.StatusCode,
              'Unexpected response');
  Check(Response.HasHeader(AllowHeader),
        'No Allow header');
  CheckEquals(Self.Core.KnownMethods,
              Response.FirstHeader(AllowHeader).Value,
              'Currently we only support one URI - as a User Agent typically '
            + 'does. Obviously that''ll eventually change');
}
end;

procedure TestTIdSipUserAgent.TestRejectNoContact;
var
  Response: TIdSipResponse;
begin
  Self.Invite.RemoveHeader(Self.Invite.FirstContact);

  Self.MarkSentResponseCount;

  Self.ReceiveInvite;

  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPBadRequest,        Response.StatusCode, 'Status-Code');
  CheckEquals(MissingContactHeader, Response.StatusText, 'Status-Text');
end;

procedure TestTIdSipUserAgent.TestRejectUnauthorizedRequest;
var
  Response: TIdSipResponse;
begin
  Self.Core.RequireAuthentication := true;

  Self.MarkSentResponseCount;
  Self.ReceiveInvite;
  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPUnauthorized,
              Response.StatusCode,
              'Status code');
  Check(Response.HasWWWAuthenticate,
        'No WWW-Authenticate header');
end;

procedure TestTIdSipUserAgent.TestRejectUnknownContentEncoding;
var
  Response: TIdSipResponse;
begin
  Self.Invite.FirstHeader(ContentTypeHeaderFull).Value := SdpMimeType;

  Self.MarkSentResponseCount;

  Self.Invite.AddHeader(ContentEncodingHeaderFull).Value := 'gzip';

  Self.ReceiveInvite;

  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPUnsupportedMediaType, Response.StatusCode, 'Status-Code');
  Check(Response.HasHeader(AcceptEncodingHeader), 'No Accept-Encoding header');
  CheckEquals('',
              Response.FirstHeader(AcceptEncodingHeader).Value,
              'Accept value');
end;

procedure TestTIdSipUserAgent.TestRejectUnknownContentLanguage;
var
  Response: TIdSipResponse;
begin
  Self.Core.AddAllowedLanguage('fr');

  Self.Invite.AddHeader(ContentLanguageHeader).Value := 'en_GB';

  Self.MarkSentResponseCount;

  Self.ReceiveInvite;

  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPUnsupportedMediaType, Response.StatusCode, 'Status-Code');
  Check(Response.HasHeader(AcceptLanguageHeader), 'No Accept-Language header');
  CheckEquals(Self.Core.AllowedLanguages,
              Response.FirstHeader(AcceptLanguageHeader).Value,
              'Accept-Language value');
end;

procedure TestTIdSipUserAgent.TestRejectUnknownContentType;
var
  Response: TIdSipResponse;
begin
  Self.MarkSentResponseCount;

  Self.Invite.ContentType := 'text/xml';

  Self.ReceiveInvite;

  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPUnsupportedMediaType, Response.StatusCode, 'Status-Code');
  Check(Response.HasHeader(AcceptHeader), 'No Accept header');
  CheckEquals(SdpMimeType,
              Response.FirstHeader(AcceptHeader).Value,
              'Accept value');
end;

procedure TestTIdSipUserAgent.TestRejectUnknownExtension;
var
  Response: TIdSipResponse;
begin
  Self.MarkSentResponseCount;

  Self.Invite.AddHeader(RequireHeader).Value := '100rel';

  Self.ReceiveInvite;

  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPBadExtension, Response.StatusCode, 'Status-Code');
  Check(Response.HasHeader(UnsupportedHeader), 'No Unsupported header');
  CheckEquals(Self.Invite.FirstHeader(RequireHeader).Value,
              Response.FirstHeader(UnsupportedHeader).Value,
              'Unexpected Unsupported header value');
end;

procedure TestTIdSipUserAgent.TestRejectUnknownScheme;
var
  Response: TIdSipResponse;
begin
  Self.MarkSentResponseCount;

  Self.Invite.RequestUri.URI := 'tel://1';
  Self.ReceiveInvite;

  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPUnsupportedURIScheme, Response.StatusCode, 'Status-Code');
end;

procedure TestTIdSipUserAgent.TestRejectUnsupportedMethod;
var
  Response: TIdSipResponse;
begin
  Self.Invite.Method := MethodRegister;
  Self.Invite.CSeq.Method := Self.Invite.Method;

  Self.MarkSentResponseCount;

  Self.ReceiveInvite;

  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPNotImplemented,
              Response.StatusCode,
              'Unexpected response');
  Check(Response.HasHeader(AllowHeader),
        'Allow header is mandatory. cf. RFC 3261 section 8.2.1');

  CheckCommaSeparatedHeaders(Self.Core.KnownMethods,
                             Response.FirstHeader(AllowHeader),
                             'Allow header');
end;

procedure TestTIdSipUserAgent.TestRejectUnsupportedSipVersion;
var
  Response: TIdSipResponse;
begin
  Self.MarkSentResponseCount;
  Self.Invite.SIPVersion := 'SIP/1.0';

  Self.ReceiveInvite;

  CheckEquals(Self.ResponseCount + 2, // Trying + reject
              Self.SentResponseCount,
              'No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPSIPVersionNotSupported,
              Response.StatusCode,
              'Status-Code');
end;

procedure TestTIdSipUserAgent.TestRemoveObserver;
var
  L1, L2: TIdObserverListener;
begin
  L1 := TIdObserverListener.Create;
  try
    L2 := TIdObserverListener.Create;
    try
      Self.Core.AddObserver(L1);
      Self.Core.AddObserver(L2);
      Self.Core.RemoveObserver(L2);

      Self.ReceiveInvite;

      Check(L1.Changed and not L2.Changed,
            'Listener notified, hence not removed');
    finally
      L2.Free
    end;
  finally
    L1.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestRemoveUserAgentListener;
var
  L1, L2: TIdSipTestUserAgentListener;
begin
  L1 := TIdSipTestUserAgentListener.Create;
  try
    L2 := TIdSipTestUserAgentListener.Create;
    try
      Self.Core.AddUserAgentListener(L1);
      Self.Core.AddUserAgentListener(L2);
      Self.Core.RemoveUserAgentListener(L2);

      Self.ReceiveInvite;

      Check(L1.InboundCall and not L2.InboundCall,
            'Listener notified, hence not removed');
    finally
      L2.Free
    end;
  finally
    L1.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestRFC2543InviteCallFlow;
const
  RawSippInvite = 'INVITE sip:service@80.168.137.82:5060 SIP/2.0'#13#10
                + 'Via: SIP/2.0/UDP 81.86.64.25:5060'#13#10
                + 'From: sipp <sip:sipp@81.86.64.25:5060>;tag=1'#13#10
                + 'To: sut <sip:service@80.168.137.82:5060>'#13#10
                + 'Call-ID: 1.87901.81.86.64.25@sipp.call.id'#13#10
                + 'CSeq: 1 INVITE'#13#10
                + 'Contact: sip:sipp@81.86.64.25:5060'#13#10
                + 'Max-Forwards: 70'#13#10
                + 'Subject: Performance Test'#13#10
                + 'Content-Length: 0'#13#10#13#10;
  RawSippAck = 'ACK sip:service@80.168.137.82:5060 SIP/2.0'#13#10
             + 'Via: SIP/2.0/UDP 81.86.64.25'#13#10
             + 'From: sipp <sip:sipp@81.86.64.25:5060>;tag=1'#13#10
             + 'To: sut <sip:service@80.168.137.82:5060>;tag=%s'#13#10
             + 'Call-ID: 1.87901.81.86.64.25@sipp.call.id'#13#10
             + 'CSeq: 1 ACK'#13#10
             + 'Contact: sip:sipp@81.86.64.25:5060'#13#10
             + 'Max-Forwards: 70'#13#10
             + 'Subject: Performance Test'#13#10
             + 'Content-Length: 0'#13#10#13#10;
  RawSippBye = 'BYE sip:service@80.168.137.82:5060 SIP/2.0'#13#10
             + 'Via: SIP/2.0/UDP 81.86.64.25'#13#10
             + 'From: sipp <sip:sipp@81.86.64.25:5060>;tag=1'#13#10
             + 'To: sut <sip:service@80.168.137.82:5060>;tag=%s'#13#10
             + 'Call-ID: 1.87901.81.86.64.25@sipp.call.id'#13#10
             + 'CSeq: 2 BYE'#13#10
             + 'Contact: sip:sipp@81.86.64.25:5060'#13#10
             + 'Max-Forwards: 70'#13#10
             + 'Subject: Performance Test'#13#10
             + 'Content-Length: 0'#13#10#13#10;
var
  SippAck:    TIdSipRequest;
  SippBye:    TIdSipRequest;
  SippInvite: TIdSipRequest;
begin
  // SIPp is a SIP testing tool: http://sipp.sourceforge.net/

  Self.Dispatcher.Transport.WriteLog := true;

  SippInvite := TIdSipRequest.ReadRequestFrom(RawSippInvite);
  try
    Self.MarkSentResponseCount;
    Self.ReceiveRequest(SippInvite);
    Check(Assigned(Self.Session),
          'OnInboundCall didn''t fire');
    Self.Session.AcceptCall('', '');

    SippAck := TIdSipRequest.ReadRequestFrom(Format(RawSippAck,
                                                    [Self.Session.Dialog.ID.LocalTag]));
    try
      Self.ReceiveRequest(SippAck);
    finally
      SippAck.Free;
    end;

    Self.MarkSentResponseCount;

    SippBye := TIdSipRequest.ReadRequestFrom(Format(RawSippBye,
                                                    [Self.Session.Dialog.ID.LocalTag]));
    try
      Self.ReceiveRequest(SippBye);
    finally
      SippBye.Free;
    end;

    CheckResponseSent('No response sent for the BYE');

    CheckEquals(SIPOK,
                Self.LastSentResponse.StatusCode,
                'Unexpected response');
  finally
    SippInvite.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestScheduleEventActionClosure;
var
  EventCount: Integer;
begin
  EventCount := Self.DebugTimer.EventCount;
  Self.Core.ScheduleEvent(TIdSipInboundInviteExpire, 50, Self.Invite.Copy);
  Check(EventCount < DebugTimer.EventCount,
        'Event not scheduled');
end;

procedure TestTIdSipUserAgent.TestSetContact;
var
  C: TIdSipContactHeader;
begin
  C := TIdSipContactHeader.Create;
  try
    C.Value := 'sip:case@fried.neurons.org';
    Self.Core.Contact := C;

    Check(Self.Core.Contact.Equals(C),
                'Contact not set');
  finally
    C.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestSetContactMailTo;
var
  C: TIdSipContactHeader;
begin
  C := TIdSipContactHeader.Create;
  try
    try
      C.Value := 'mailto:wintermute@tessier-ashpool.co.luna';
      Self.Core.Contact := C;
      Fail('Only a SIP or SIPs URI may be specified');
    except
      on EBadHeader do;
    end;
  finally
    C.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestSetContactWildCard;
var
  C: TIdSipContactHeader;
begin
  C := TIdSipContactHeader.Create;
  try
    try
      C.Value := '*';
      Self.Core.Contact := C;
      Fail('Wildcard Contact headers make no sense in a response that sets up '
         + 'a dialog');
    except
      on EBadHeader do;
      on EAssertionFailed do;
    end;
  finally
    C.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestSetFrom;
var
  F: TIdSipFromHeader;
begin
  F := TIdSipFromHeader.Create;
  try
    F.Value := 'sip:case@fried.neurons.org';
    Self.Core.From := F;

    Check(Self.Core.From.Equals(F),
          'From not set');
  finally
    F.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestSetFromMailTo;
var
  F: TIdSipFromHeader;
begin
  F := TIdSipFromHeader.Create;
  try
    try
      F.Value := 'mailto:wintermute@tessier-ashpool.co.luna';
      Self.Core.From := F;
      Fail('Only a SIP or SIPs URI may be specified');
    except
      on EBadHeader do;
    end;
  finally
    F.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestSimultaneousInAndOutboundCall;
begin
  Self.Core.InviteModule.Call(Self.Destination, '', '').Send;
  Self.ReceiveTrying(Self.LastSentRequest);
  Self.ReceiveRinging(Self.LastSentRequest);

  Self.ReceiveInvite;
  Check(Assigned(Self.Session), 'TU not informed of inbound call');

  Self.Session.AcceptCall('', '');
  CheckEquals(2, Self.Core.SessionCount, 'Session count');
end;

procedure TestTIdSipUserAgent.TestTerminateAllCalls;
var
  InboundSession: TIdSipInboundSession;
  Sess:           TIdSipSession;
begin
  // We have:
  // * an established inbound call;
  // * an unestablished inbound call;
  // * an unestablished outbound call;
  // * an established outbound call.
  // When we terminate everything, we expect only the unestablished outbound
  // call to remain, because it can only terminate according to RFC 3261 section 9.1

  Self.ReceiveInvite;
  Check(Assigned(Self.Session), 'OnInboundCall didn''t fire, first INVITE');
  InboundSession := Self.Session;
  InboundSession.AddSessionListener(Self);
  InboundSession.AcceptCall('', '');
  Self.ReceiveAck;

  Self.Invite.LastHop.Branch := Self.Invite.LastHop.Branch + '1';
  Self.Invite.From.Tag       := Self.Invite.From.Tag + '1';
  Self.ReceiveInvite;

  Sess := Self.Core.InviteModule.Call(Self.Destination, '', '');
  Sess.AddSessionListener(Self);
  Sess.Send;
  Self.ReceiveTrying(Self.LastSentRequest);

  Sess := Self.Core.InviteModule.Call(Self.Destination, '', '');
  Sess.AddSessionListener(Self);
  Sess.Send;
  Self.ReceiveOk(Self.LastSentRequest);

  CheckEquals(4,
              Self.Core.SessionCount,
              'Session count');

  Self.Core.TerminateAllCalls;

  // This looks completely wrong, I know. However, we've sent a CANCEL to
  // terminate the not-yet-accepted INVITE we sent out with Call(). That
  // session won't end until we receive a 487 Request Terminated for that INVITE
  // or we receive a 200 OK (in which case we send a BYE and immediately tear
  // down the session), or we time out (because the remote end was an RFC 2543
  // UAS). cf RFC 3261 section 9.1
  CheckEquals(1,
              Self.Core.SessionCount,
              'Session count after TerminateAllCalls');
end;

procedure TestTIdSipUserAgent.TestUnknownAcceptValue;
begin
  Self.Invite.AddHeader(AcceptHeader).Value := 'text/unsupportedtextvalue';

  Self.MarkSentResponseCount;
  Self.ReceiveInvite;

  Self.CheckResponseSent('No response sent to INVITE');
  CheckEquals(SIPNotAcceptableClient,
              Self.LastSentResponse.StatusCode,
              'Inappropriate response');
  Check(Self.LastSentResponse.HasHeader(AcceptHeader),
        'Response missing Accept header');
  CheckEquals(Self.Core.AllowedContentTypes,
              Self.LastSentResponse.FirstHeader(AcceptHeader).Value,
              'Incorrect Accept header');
end;

procedure TestTIdSipUserAgent.TestUnmatchedAckGetsDropped;
var
  Ack:      TIdSipRequest;
  Listener: TIdSipTestUserAgentListener;
begin
  Listener := TIdSipTestUserAgentListener.Create;
  try
    Self.Core.AddUserAgentListener(Listener);

    Self.MarkSentResponseCount;
    Ack := TIdSipRequest.Create;
    try
      Ack.Assign(Self.Invite);
      Ack.Method      := MethodAck;
      Ack.CSeq.Method := Ack.Method;

      Self.ReceiveRequest(Ack);
    finally
      Ack.Free;
    end;

    Check(Listener.DroppedUnmatchedMessage,
          'Unmatched ACK not dropped');
    Check(Listener.AbstractUserAgentParam = Self.Core,
          'UserAgent param of Session''s DroppedUnmatchedMessage notification wrong');
    CheckNoResponseSent('Sent a response to an unmatched ACK');
  finally
    Self.Core.RemoveUserAgentListener(Listener);
    Listener.Free;
  end;
end;

procedure TestTIdSipUserAgent.TestViaMatchesTransportParameter;
begin
  // Iterate over the registered transports? Or does
  // TIdSipTransport.TransportFor return the null transport instead?

  Self.Dispatcher.TransportType := UdpTransport;
  Self.Destination.Address.Transport := Self.Dispatcher.Transport.GetTransportType;
  Self.Core.InviteModule.Call(Self.Destination, '', '').Send;

  CheckEquals(Self.Dispatcher.Transport.GetTransportType,
              Self.LastSentRequest.LastHop.Transport,
              'Transport parameter = '
            + Self.Destination.Address.Transport);

  Self.Dispatcher.TransportType := TlsTransport;
  Self.Destination.Address.Transport := Self.Dispatcher.Transport.GetTransportType;
  Self.Core.InviteModule.Call(Self.Destination, '', '').Send;

  CheckEquals(Self.Dispatcher.Transport.GetTransportType,
              Self.LastSentRequest.LastHop.Transport,
              'Transport parameter = '
            + Self.Destination.Address.Transport);
end;

//******************************************************************************
//* TestTIdSipStackConfigurator                                                *
//******************************************************************************
//* TestTIdSipStackConfigurator Public methods *********************************

procedure TestTIdSipStackConfigurator.SetUp;
begin
  inherited SetUp;

  Self.Address       := '127.0.0.1';
  Self.Conf          := TIdSipStackConfigurator.Create;
  Self.Configuration := TStringList.Create;
  Self.Port          := 15060;
  Self.Timer         := TIdTimerQueue.Create(true);
  Self.Server        := TIdUDPServer.Create(nil);
  Self.Server.DefaultPort   := Self.Port + 10000;
  Self.Server.OnUDPRead     := Self.NoteReceiptOfPacket;
  Self.Server.ThreadedEvent := true;
  Self.Server.Active        := true;

  TIdSipTransportRegistry.RegisterTransport(TcpTransport, TIdSipTCPTransport);
  TIdSipTransportRegistry.RegisterTransport(UdpTransport, TIdSipUDPTransport);

  Self.ReceivedPacket := false;

end;

procedure TestTIdSipStackConfigurator.TearDown;
begin
  TIdSipTransportRegistry.UnregisterTransport(UdpTransport);
  TIdSipTransportRegistry.UnregisterTransport(TcpTransport);

  Self.Server.Free;
  Self.Timer.Terminate;
  Self.Configuration.Free;
  Self.Conf.Free;

  inherited TearDown;
end;

//* TestTIdSipStackConfigurator Private methods ********************************

function TestTIdSipStackConfigurator.ARecords: String;
begin

  // Dig would translate this data as
  // ;; QUERY SECTION:
  // ;;      paranoid.leo-ix.net, type = A, class = IN
  //
  // ;; ANSWER SECTION:
  // paranoid.leo-ix.net.    1H IN A         127.0.0.2
  // paranoid.leo-ix.net.    1H IN A         127.0.0.1
  //
  // ;; AUTHORITY SECTION:
  // leo-ix.net.             1H IN NS        ns1.leo-ix.net.
  //
  // ;; ADDITIONAL SECTION:
  // ns1.leo-ix.net.         1H IN A         127.0.0.1

  Result :=
  { hdr id }#$85#$80#$00#$01#$00#$02#$00#$01#$00#$01#$08#$70#$61#$72
  + #$61#$6E#$6F#$69#$64#$06#$6C#$65#$6F#$2D#$69#$78#$03#$6E#$65#$74
  + #$00#$00#$01#$00#$01#$C0#$0C#$00#$01#$00#$01#$00#$00#$0E#$10#$00
  + #$04#$7F#$00#$00#$01#$C0#$0C#$00#$01#$00#$01#$00#$00#$0E#$10#$00
  + #$04#$7F#$00#$00#$02#$C0#$15#$00#$02#$00#$01#$00#$00#$0E#$10#$00
  + #$06#$03#$6E#$73#$31#$C0#$15#$C0#$51#$00#$01#$00#$01#$00#$00#$0E
  + #$10#$00#$04#$7F#$00#$00#$01;
end;

procedure TestTIdSipStackConfigurator.CheckAutoContact(UserAgent: TIdSipAbstractUserAgent);
begin
  CheckEquals(UTF16LEToUTF8(GetFullUserName),
              UserAgent.Contact.DisplayName,
              'display-name');
  CheckEquals(UTF16LEToUTF8(GetUserName),
              UserAgent.Contact.Address.Username,
              'user-info');
  CheckEquals(LocalAddress,
              UserAgent.Contact.Address.Host,
              'host-info');
end;

procedure TestTIdSipStackConfigurator.NoteReceiptOfPacket(Sender: TObject;
                                                          AData: TStream;
                                                          ABinding: TIdSocketHandle);
begin
  Self.ReceivedPacket := true;
  Self.ThreadEvent.SetEvent;
end;

procedure TestTIdSipStackConfigurator.ProvideAnswer(Sender: TObject;
                                                    AData: TStream;
                                                    ABinding: TIdSocketHandle);
var
  Answer:  String;
  ReplyID: String;
  S:       TStringStream;
begin
  S := TStringStream.Create('');
  try
    S.CopyFrom(AData, 0);

    ReplyID := Copy(S.DataString, 1, 2);
  finally
    S.Free;
  end;

  Answer := ReplyID + Self.ARecords;

  Self.Server.Send(ABinding.PeerIP,
                   ABinding.PeerPort,
                   Answer);

  Self.NoteReceiptOfPacket(Sender, AData, ABinding);
end;

//* TestTIdSipStackConfigurator Published methods ******************************

procedure TestTIdSipStackConfigurator.TestCreateUserAgentHandlesMultipleSpaces;
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Listen  :     TCP 127.0.0.1:5060');

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    CheckEquals(TIdSipTCPTransport.ClassName,
                UA.Dispatcher.Transports[0].ClassName,
                'Transport type');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentHandlesTabs;
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Listen'#9':'#9'TCP 127.0.0.1:5060');

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    CheckEquals(TIdSipTCPTransport.ClassName,
                UA.Dispatcher.Transports[0].ClassName,
                'Transport type');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentRegisterDirectiveBeforeTransport;
var
  UA: TIdSipUserAgent;
begin
  // Any network actions (like registering) can only happen once we've
  // configured the Transport layer. Same goes for configuring the NameServer.
  Self.Configuration.Add('Register: sip:127.0.0.1:' + IntToStr(Self.Server.DefaultPort));
  Self.Configuration.Add('Listen: UDP 127.0.0.1:5060');
  Self.Configuration.Add('NameServer: MOCK');

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    Self.WaitForSignaled('Waiting for REGISTER');
    Check(Self.ReceivedPacket, 'No REGISTER received');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentReturnsSomething;
var
  UA: TIdSipUserAgent;
begin
  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    Check(Assigned(UA), 'CreateUserAgent didn''t return anything');
    Check(Assigned(UA.Dispatcher), 'Stack doesn''t have a Transaction layer');

    Check(Assigned(UA.Authenticator),
          'Transaction-User layer has no Authenticator');
    Check(Assigned(UA.Locator),
          'Transaction-User layer has no Locator');
    Check(Assigned(UA.Timer),
          'Transaction-User layer has no timer');
    Check(UA.Timer = UA.Dispatcher.Timer,
          'Transaction and Transaction-User layers have different timers');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithAutoTransport;
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Listen: UDP AUTO:5060');

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    CheckEquals(LocalAddress,
                UA.Dispatcher.Transports[0].Address,
                'Local NIC (or loopback) address not used');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithAutoContact;
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Contact: AUTO');

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    Self.CheckAutoContact(UA);
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithContact;
const
  DisplayName = 'Count Zero';
  ContactUri  = 'sip:countzero@jammer.org';
  Contact     = '"' + DisplayName + '" <' + ContactUri + '>';
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Contact: ' + Contact);

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    CheckEquals(DisplayName, UA.Contact.DisplayName,      'Contact display-name');
    CheckEquals(ContactUri,  UA.Contact.Address.AsString, 'Contact URI');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithFrom;
const
  DisplayName = 'Count Zero';
  FromUri     = 'sip:countzero@jammer.org';
  From        = '"' + DisplayName + '" <' + FromUri + '>';
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('From: ' + From);

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    CheckEquals(DisplayName, UA.From.DisplayName,      'From display-name');
    CheckEquals(FromUri,     UA.From.Address.AsString, 'From URI');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithLocator;
var
  UA: TIdSipUserAgent;
begin
  // This looks confusing. It isn't. We give the name server & port of Server,
  // and an unused port as the registrar. That's just because we don't care
  // about the REGISTER message - we just want to make sure the UA sends a DNS
  // query to the name server specified in the configuration.

  Self.Configuration.Add('Listen: UDP ' + Self.Address + ':' + IntToStr(Self.Port));
  Self.Configuration.Add('NameServer: 127.0.0.1:' + IntToStr(Self.Server.DefaultPort));
  Self.Configuration.Add('Register: sip:localhost:' + IntToStr(Self.Server.DefaultPort + 1));
  Self.Server.OnUDPRead := Self.ProvideAnswer;

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    Check(Assigned(UA.Locator),
          'Transaction-User has no Locator');
    Self.WaitForSignaled('Waiting for DNS query');
    Check(Self.ReceivedPacket, 'No DNS query sent to name server');

    Check(Assigned(UA.Dispatcher.Locator),
          'No Locator assigned to the Transaction layer');
    Check(UA.Locator = UA.Dispatcher.Locator,
          'Transaction and Transaction-User layers have different Locators');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithMalformedContact;
const
  MalformedContactLine = '"Count Zero <sip:countzero@jammer.org>';
begin
  Self.Configuration.Add('Contact: ' + MalformedContactLine);

  try
    Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
    Fail('Failed to bail out with malformed Contact');
  except
    on E: EParserError do
      Check(Pos(MalformedContactLine, E.Message) > 0,
            'Insufficient error message');
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithMalformedFrom;
const
  MalformedFromLine = '"Count Zero <sip:countzero@jammer.org>';
begin
  Self.Configuration.Add('From: ' + MalformedFromLine);

  try
    Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
    Fail('Failed to bail out with malformed From');
  except
    on E: EParserError do
      Check(Pos(MalformedFromLine, E.Message) > 0,
            'Insufficient error message');
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithMalformedLocator;
const
  MalformedNameServerLine = 'NameServer: 127.0.0.1:aa';
begin
  Self.Configuration.Add(MalformedNameServerLine);

  try
    Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
    Fail('Failed to bail out with malformed locator port');
  except
    on E: EParserError do
      Check(Pos(MalformedNameServerLine, E.Message) > 0,
            'Insufficient error message');
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithMalformedProxy;
const
  MalformedProxyLine = 'Proxy: sip://localhost'; // SIP URIs don't use "//"
begin
  Self.Configuration.Add(MalformedProxyLine);

  try
    Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
    Fail('Failed to bail out with malformed proxy');
  except
    on E: EParserError do
      Check(Pos(MalformedProxyLine, E.Message) > 0,
            'Insufficient error message');
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithMockAuthenticator;
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Authentication: MOCK');

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    CheckEquals(TIdSipMockAuthenticator.ClassName,
                UA.Authenticator.ClassName,
                'Authenticator type');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithMockLocator;
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('NameServer: MOCK');

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    CheckEquals(TIdSipMockLocator.ClassName,
                UA.Locator.ClassName,
                'Locator type');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithNoContact;
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Listen: UDP ' + Self.Address + ':' + IntToStr(Self.Port));

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    Self.CheckAutoContact(UA);
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithNoFrom;
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Listen: UDP ' + Self.Address + ':' + IntToStr(Self.Port));

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    Check(Assigned(UA.From),
          'UserAgent has no From at all');
    CheckNotEquals('', UA.From.Address.AsString,
                   'No From address');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithProxy;
const
  ProxyUri = 'sip:localhost';
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Listen: UDP ' + Self.Address + ':' + IntToStr(Self.Port));
  Self.Configuration.Add('Proxy: ' + ProxyUri);

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    Check(UA.HasProxy, 'No proxy specified');
    CheckEquals(ProxyUri,
                UA.Proxy.AsString,
                'Wrong proxy specified');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithRegistrar;
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Listen: UDP ' + Self.Address + ':' + IntToStr(Self.Port));
  Self.Configuration.Add('NameServer: MOCK');
  Self.Configuration.Add('Register: sip:127.0.0.1:' + IntToStr(Self.Server.DefaultPort));

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    Self.WaitForSignaled('Waiting for REGISTER');
    Check(Self.ReceivedPacket, 'No REGISTER sent to registrar');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentWithOneTransport;
var
  UA: TIdSipUserAgent;
begin
  Self.Configuration.Add('Listen: TCP ' + Self.Address + ':' + IntToStr(Self.Port));

  UA := Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
  try
    CheckEquals(1, UA.Dispatcher.TransportCount, 'Number of transports');
    CheckEquals(TIdSipTCPTransport.ClassName,
                UA.Dispatcher.Transports[0].ClassName,
                'Transport type');
    CheckEquals(Port,
                UA.Dispatcher.Transports[0].Port,
                'Transport port');
    CheckEquals(Self.Address,
                UA.Dispatcher.Transports[0].Address,
                'Transport address');
    CheckEquals(Self.Address,
                UA.Dispatcher.Transports[0].HostName,
                'Transport hostname');
    Check(Assigned(UA.Dispatcher.Transports[0].Timer),
          'Transport has no timer');
    Check(UA.Dispatcher.Timer = UA.Dispatcher.Transports[0].Timer,
          'Transport and Transaction layers have different timers');
  finally
    UA.Free;
  end;
end;

procedure TestTIdSipStackConfigurator.TestCreateUserAgentTransportHaMalformedPort;
begin
  Self.Configuration.Add('Listen: TCP ' + Self.Address + ':aa');

  try
    Self.Conf.CreateUserAgent(Self.Configuration, Self.Timer);
    Fail('Failed to bail out from a malformed port configuration');
  except
    on EParserError do;
  end;
end;

//******************************************************************************
//* TestTIdSipInviteModule                                                     *
//******************************************************************************
//* TestTIdSipInviteModule Public **********************************************

procedure TestTIdSipInviteModule.SetUp;
var
  Invite:   TIdSipRequest;
  Response: TIdSipResponse;
begin
  inherited SetUp;

  Self.Module := Self.Core.ModuleFor(MethodInvite) as TIdSipInviteModule;

  Invite := TIdSipTestResources.CreateBasicRequest;
  try
    Response := TIdSipTestResources.CreateBasicResponse;
    try
      Self.Dlg := TIdSipDialog.CreateInboundDialog(Invite,
                                                   Response,
                                                   false);
      Self.Dlg.ReceiveRequest(Invite);
      Self.Dlg.ReceiveResponse(Response)
    finally
      Response.Free;
    end;
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipInviteModule.CheckCommaSeparatedHeaders(const ExpectedValues: String;
                                                            Header: TIdSipHeader;
                                                            const Msg: String);
var
  Hdr:    TIdSipCommaSeparatedHeader;
  I:      Integer;
  Values: TStringList;
begin
  CheckEquals(TIdSipCommaSeparatedHeader.ClassName,
              Header.ClassName,
              Msg + ': Unexpected header type in CheckCommaSeparatedHeaders');

  Hdr := Header as TIdSipCommaSeparatedHeader;
  Values := TStringList.Create;
  try
    Values.CommaText := ExpectedValues;

    for I := 0 to Values.Count - 1 do
      CheckEquals(Values[I],
                  Hdr.Values[I],
                  Msg + ': ' + IntToStr(I + 1) + 'th value');
  finally
    Values.Free;
  end;
end;

procedure TestTIdSipInviteModule.CheckCreateRequest(Dest: TIdSipToHeader;
                                                    Request: TIdSipRequest);
var
  Contact: TIdSipContactHeader;
begin
  CheckEquals(Dest.Address,
              Request.RequestUri,
              'Request-URI not properly set');

  Check(Request.HasHeader(CallIDHeaderFull), 'No Call-ID header added');
  CheckNotEquals('',
                 (Request.FirstHeader(CallIDHeaderFull) as TIdSipCallIdHeader).Value,
                 'Call-ID must not be empty');

  Check(Request.HasHeader(ContactHeaderFull), 'No Contact header added');
  Contact := Request.FirstContact;
  Check(Contact.Equals(Self.Core.Contact), 'Contact header incorrectly set');

  CheckEquals(Request.From.DisplayName,
              Self.Core.From.DisplayName,
              'From.DisplayName');
  CheckEquals(Request.From.Address,
              Self.Core.From.Address,
              'From.Address');
    Check(Request.From.HasTag,
          'Requests MUST have a From tag; cf. RFC 3261 section 8.1.1.3');

  CheckEquals(Request.RequestUri,
              Request.ToHeader.Address,
              'To header incorrectly set');

  CheckEquals(1,
              Request.Path.Length,
              'New requests MUST have a Via header; cf. RFC 3261 section 8.1.1.7');
  Check(Request.LastHop.HasBranch,
        'New requests MUST have a branch; cf. RFC 3261 section 8.1.1.7');
  CheckEquals(UdpTransport,
              Request.LastHop.Transport,
              'UDP should be the default transport');
end;

//* TestTIdSipInviteModule Published *******************************************

procedure TestTIdSipInviteModule.TestCreateAck;
var
  Ack: TIdSipRequest;
begin
  Ack := Self.Module.CreateAck(Self.Dlg);
  try
    CheckEquals(1, Ack.Path.Count, 'Wrong number of Via headers');
  finally
    Ack.Free;
  end;
end;

procedure TestTIdSipInviteModule.TestCreateBye;
var
  Bye: TIdSipRequest;
begin
  Bye := Self.Module.CreateBye(Self.Dlg);
  try
    CheckEquals(MethodBye, Bye.Method, 'Unexpected method');
    CheckEquals(Bye.Method,
                Bye.CSeq.Method,
                'CSeq method doesn''t match request method');
  finally
    Bye.Free;
  end;
end;

procedure TestTIdSipInviteModule.TestCreateInvite;
var
  Dest:    TIdSipToHeader;
  Request: TIdSipRequest;
begin
  Dest := TIdSipToHeader.Create;
  try
    Dest.Address.URI := 'sip:wintermute@tessier-ashpool.co.luna';
    Request := Self.Module.CreateInvite(Dest, '', '');
    try
      Self.CheckCreateRequest(Dest, Request);
      CheckEquals(MethodInvite, Request.Method, 'Incorrect method');

      Check(not Request.ToHeader.HasTag,
            'This request is outside of a dialog, hence MUST NOT have a '
          + 'To tag. See RFC:3261, section 8.1.1.2');

      Check(Request.HasHeader(CSeqHeader), 'No CSeq header');
      Check(not Request.HasHeader(ContentDispositionHeader),
            'Needless Content-Disposition header');

      Check(Request.HasHeader(AllowHeader), 'No Allow header');
      CheckCommaSeparatedHeaders(Self.Core.KnownMethods,
                                 Request.FirstHeader(AllowHeader),
                                 'Allow header');

      Check(Request.HasHeader(SupportedHeaderFull), 'No Supported header');
      CheckEquals(Self.Core.AllowedExtensions,
                  Request.FirstHeader(SupportedHeaderFull).Value,
                  'Supported header value');
    finally
      Request.Free;
    end;
  finally
    Dest.Free;
  end;
end;

procedure TestTIdSipInviteModule.TestCreateInviteInsideDialog;
var
  Invite: TIdSipRequest;
begin
  Invite := Self.Module.CreateReInvite(Self.Dlg, '', '');
  try
      Check(Invite.ToHeader.HasTag,
            'This request is inside a dialog, hence MUST have a '
          + 'To tag. See RFC:3261, section 12.2.1.1');
      CheckEquals(Self.Dlg.ID.RemoteTag,
                  Invite.ToHeader.Tag,
                  'To tag');

      Check(Invite.HasHeader(CSeqHeader), 'No CSeq header');
      Check(not Invite.HasHeader(ContentDispositionHeader),
            'Needless Content-Disposition header');

    Check(Invite.HasHeader(AllowHeader), 'No Allow header');
    CheckCommaSeparatedHeaders(Self.Core.KnownMethods,
                               Invite.FirstHeader(AllowHeader),
                               'Allow header');

    Check(Invite.HasHeader(SupportedHeaderFull), 'No Supported header');
    CheckEquals(Self.Core.AllowedExtensions,
                Invite.FirstHeader(SupportedHeaderFull).Value,
                'Supported header value');
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipInviteModule.TestCreateInviteWithBody;
var
  Invite: TIdSipRequest;
  Body:   String;
begin
  Body := 'foo fighters';

  Invite := Self.Module.CreateInvite(Self.Destination, Body, 'text/plain');
  try
    CheckEquals(Length(Body), Invite.ContentLength, 'Content-Length');
    CheckEquals(Body,         Invite.Body,          'Body');

    Check(Invite.HasHeader(ContentDispositionHeader),
          'Missing Content-Disposition');
    CheckEquals(DispositionSession,
                Invite.ContentDisposition.Value,
                'Content-Disposition value');
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipInviteModule.TestCreateReInvite;
var
  Invite: TIdSipRequest;
begin
  Invite := Self.Module.CreateReInvite(Self.Dlg, 'foo', 'bar');
  try
    CheckEquals(MethodInvite, Invite.Method, 'Method');
    CheckEquals('foo',        Invite.Body, 'Body');
    CheckEquals('bar',        Invite.ContentType, 'Content-Type');

    CheckEquals(Self.Dlg.ID.CallID,
                Invite.CallID,
                'Call-ID');
    CheckEquals(Self.Dlg.ID.LocalTag,
                Invite.From.Tag,
                'From tag');
    CheckEquals(Self.Dlg.ID.RemoteTag,
                Invite.ToHeader.Tag,
                'To tag');
    CheckEquals(Self.Dlg.LocalSequenceNo,
                Invite.CSeq.SequenceNo,
                'CSeq sequence no');
  finally
    Invite.Free;
  end;
end;

//******************************************************************************
//* TestTIdSipInboundInvite                                                    *
//******************************************************************************
//* TestTIdSipInboundInvite Public methods *************************************

procedure TestTIdSipInboundInvite.SetUp;
var
  Ok: TIdSipResponse;
begin
  inherited SetUp;

  Self.Module := Self.Core.ModuleFor(MethodInvite) as TIdSipInviteModule;

  Ok := TIdSipResponse.InResponseTo(Self.Invite, SIPOK);
  try
    Ok.ToHeader.Tag := Self.Core.NextTag;
    Self.Dialog := TIdSipDialog.CreateInboundDialog(Self.Invite, Ok, true);
  finally
    Ok.Free;
  end;

  Self.Answer         := '';
  Self.Failed         := false;
  Self.OnSuccessFired := false;
  Self.ToTag          := 'foo-tag';

  Self.InviteAction := TIdSipInboundInvite.CreateInbound(Self.Core, Self.Invite, false);
  Self.InviteAction.LocalTag := Self.ToTag;
  Self.InviteAction.AddListener(Self);
end;

procedure TestTIdSipInboundInvite.TearDown;
begin
  Self.InviteAction.Free;
  Self.Dialog.Free;

  inherited TearDown;
end;

//* TestTIdSipInboundInvite Private methods ************************************

procedure TestTIdSipInboundInvite.CheckAck(InviteAction: TIdSipInboundInvite);
var
  Ack:          TIdSipRequest;
  RemoteDialog: TIdSipDialog;
begin
  InviteAction.Accept('', '');

  RemoteDialog := TIdSipDialog.CreateOutboundDialog(InviteAction.InitialRequest,
                                                    Self.LastSentResponse,
                                                    false);
  try
    RemoteDialog.ReceiveRequest(InviteAction.InitialRequest);
    RemoteDialog.ReceiveResponse(Self.LastSentResponse);

    Ack := Self.Module.CreateAck(RemoteDialog);
    try
      Check(InviteAction.Match(Ack),
            'ACK must match the InviteAction');
    finally
      Ack.Free;
    end;
  finally
    RemoteDialog.Free;
  end;
end;

procedure TestTIdSipInboundInvite.CheckAckWithDifferentCSeq(InviteAction: TIdSipInboundInvite);
var
  Ack:          TIdSipRequest;
  RemoteDialog: TIdSipDialog;
begin
  InviteAction.Accept('', '');

  RemoteDialog := TIdSipDialog.CreateOutboundDialog(InviteAction.InitialRequest,
                                                    Self.LastSentResponse,
                                                    false);
  try
    RemoteDialog.ReceiveRequest(InviteAction.InitialRequest);
    RemoteDialog.ReceiveResponse(Self.LastSentResponse);

    Ack := Self.Module.CreateAck(RemoteDialog);
    try
      Ack.CSeq.Increment;
      Check(not InviteAction.Match(Ack),
            'ACK must not match the InviteAction');
    finally
      Ack.Free;
    end;
  finally
    RemoteDialog.Free;
  end;
end;

procedure TestTIdSipInboundInvite.OnFailure(InviteAgent: TIdSipInboundInvite);
begin
  Self.Failed := true;
end;

procedure TestTIdSipInboundInvite.OnSuccess(InviteAgent: TIdSipInboundInvite;
                                            Ack: TIdSipRequest);
begin
  Self.Answer         := Ack.Body;
  Self.AnswerMimeType := Ack.ContentType;
  Self.OnSuccessFired := true;
end;

//* TestTIdSipInboundInvite Published methods **********************************

procedure TestTIdSipInboundInvite.TestAccept;
var
  Body:        String;
  ContentType: String;
  Response:    TIdSipResponse;
begin
  Self.MarkSentResponseCount;

  Body        := 'foo';
  ContentType := 'bar';
  Self.InviteAction.Accept(Body, ContentType);

  CheckResponseSent('No response sent');
  Response := Self.LastSentResponse;
  CheckEquals(SIPOK,
              Response.StatusCode,
              'Unexpected Status-Code');

  Check(Response.From.HasTag,                  'No From tag');
  Check(Response.ToHeader.HasTag,              'No To tag');
  Check(Response.HasHeader(ContactHeaderFull), 'No Contact header');

  CheckEquals(Self.ToTag,
              Response.ToHeader.Tag,
              'To (local) tag');
  CheckEquals(Body,
              Response.Body,
              'Body');
  CheckEquals(ContentType,
              Response.ContentType,
              'Content-Type');
end;

procedure TestTIdSipInboundInvite.TestCancelAfterAccept;
var
  Cancel:         TIdSipRequest;
  CancelResponse: TIdSipResponse;
  InviteResponse: TIdSipResponse;
begin
  // <--- INVITE ---
  //  --- 200 OK --->
  // <---  ACK   ---
  // <--- CANCEL ---
  //  --- 200 OK --->

  Self.InviteAction.Accept('', '');

  Self.MarkSentResponseCount;
  Cancel := Self.Invite.CreateCancel;
  try
    Self.InviteAction.ReceiveRequest(Cancel);
  finally
    Cancel.Free;
  end;

  Check(not Self.InviteAction.IsTerminated,
        'Action terminated');
  Check(not Self.Failed,
        'Listeners notified of (false) failure');

  CheckResponseSent('No response sent');

  CancelResponse := Self.LastSentResponse;
  InviteResponse := Self.Dispatcher.Transport.SecondLastResponse;

  CheckEquals(SIPOK,
              CancelResponse.StatusCode,
              'Unexpected Status-Code for CANCEL response');
  CheckEquals(MethodCancel,
              CancelResponse.CSeq.Method,
              'Unexpected CSeq method for CANCEL response');

  CheckEquals(SIPOK,
              InviteResponse.StatusCode,
              'Unexpected Status-Code for INVITE response');
  CheckEquals(MethodInvite,
              InviteResponse.CSeq.Method,
              'Unexpected CSeq method for INVITE response');
end;

procedure TestTIdSipInboundInvite.TestCancelBeforeAccept;
var
  Cancel: TIdSipRequest;
begin
  // <---         INVITE         ---
  // <---         CANCEL         ---
  //  ---         200 OK         ---> (for the CANCEL)
  //  --- 487 Request Terminated ---> (for the INVITE)
  // <---           ACK          ---

  Cancel := Self.Invite.CreateCancel;
  try
    Self.InviteAction.ReceiveRequest(Cancel);
  finally
    Cancel.Free;
  end;

  Check(Self.InviteAction.IsTerminated,
        'Action not marked as terminated');
  Check(Self.Failed,
        'Listeners not notified of failure');
end;

procedure TestTIdSipInboundInvite.TestInviteWithNoOffer;
var
  Ack:    TIdSipRequest;
  Action: TIdSipInboundInvite;
  Answer: String;
  Offer:  String;
begin
  // <---       INVITE        ---
  //  --- 200 OK (with offer) --->
  // <---  ACK (with answer)  ---

  Answer := TIdSipTestResources.BasicSDP('4.3.2.1');
  Offer  := TIdSipTestResources.BasicSDP('1.2.3.4');

  Self.Invite.Body := '';
  Self.Invite.RemoveAllHeadersNamed(ContentTypeHeaderFull);

  Action := TIdSipInboundInvite.CreateInbound(Self.Core, Self.Invite, false);
  Action.AddListener(Self);

  Self.MarkSentResponseCount;
  Action.Accept(Offer,
                SdpMimeType);

  Self.CheckResponseSent('No 2xx sent');
  CheckEquals(Offer,
              Self.LastSentResponse.Body,
              'Body of 2xx');
  CheckEquals(SdpMimeType,
              Self.LastSentResponse.ContentType,
              'Content-Type of 2xx');

  Ack := Self.Invite.AckFor(Self.LastSentResponse);
  try
    Ack.Body                        := Answer;
    Ack.ContentDisposition.Handling := DispositionSession;
    Ack.ContentLength               := Length(Answer);
    Ack.ContentType                 := Self.LastSentResponse.ContentType;

    Action.ReceiveRequest(Ack);
  finally
    Ack.Free;
  end;

  Check(Self.OnSuccessFired,
        'InviteAction never received the ACK');

  CheckEquals(Answer,
              Self.Answer,
              'ACK''s body');
  CheckEquals(Self.LastSentResponse.ContentType,
              Self.AnswerMimeType,
              'ACK''s Content-Type');
end;

procedure TestTIdSipInboundInvite.TestIsInbound;
begin
  Check(Self.InviteAction.IsInbound,
        Self.InviteAction.ClassName + ' not marked as inbound');
end;

procedure TestTIdSipInboundInvite.TestIsInvite;
begin
  Check(Self.InviteAction.IsInvite,
        Self.InviteAction.ClassName + ' not marked as a Invite');
end;

procedure TestTIdSipInboundInvite.TestIsOptions;
begin
  Check(not Self.InviteAction.IsOptions,
        Self.InviteAction.ClassName + ' marked as an Options');
end;

procedure TestTIdSipInboundInvite.TestIsRegistration;
begin
  Check(not Self.InviteAction.IsRegistration,
        Self.InviteAction.ClassName + ' marked as a Registration');
end;

procedure TestTIdSipInboundInvite.TestIsSession;
begin
  Check(not Self.InviteAction.IsSession,
        Self.InviteAction.ClassName + ' marked as a Session');
end;

procedure TestTIdSipInboundInvite.TestMatchAck;
begin
  Self.InviteAction.Accept('', '');

  Self.CheckAck(Self.InviteAction);
end;

procedure TestTIdSipInboundInvite.TestMatchAckToReInvite;
var
  Action: TIdSipInboundInvite;
begin
  // We want an in-dialog action
  Self.Invite.ToHeader.Tag := Self.Core.NextTag;

  Action := TIdSipInboundInvite.CreateInbound(Self.Core, Self.Invite, false);
  try
    Action.Accept('', '');

    Self.CheckAck(Action);
  finally
    Action.Free;
  end;
end;

procedure TestTIdSipInboundInvite.TestMatchAckToReInviteWithDifferentCSeq;
var
  Action: TIdSipInboundInvite;
begin
  // We want an in-dialog action
  Self.Invite.ToHeader.Tag := Self.Core.NextTag;

  Action := TIdSipInboundInvite.CreateInbound(Self.Core, Self.Invite, false);
  try
    Self.CheckAckWithDifferentCSeq(Action);
  finally
    Action.Free;
  end;
end;

procedure TestTIdSipInboundInvite.TestMatchAckWithDifferentCSeq;
begin
  Self.CheckAckWithDifferentCSeq(Self.InviteAction);
end;

procedure TestTIdSipInboundInvite.TestMethod;
begin
  CheckEquals(MethodInvite,
              TIdSipInboundInvite.Method,
              'Inbound INVITE Method');
end;

procedure TestTIdSipInboundInvite.TestNotifyOfNetworkFailure;
var
  L1, L2: TIdSipTestInboundInviteListener;
begin
  L1 := TIdSipTestInboundInviteListener.Create;
  try
    L2 := TIdSipTestInboundInviteListener.Create;
    try
      Self.InviteAction.AddListener(L1);
      Self.InviteAction.AddListener(L2);

      Self.Dispatcher.Transport.FailWith := EIdConnectTimeout;

      Self.InviteAction.Accept('', '');

      Check(Self.InviteAction.IsTerminated, 'Action not marked as terminated');
      Check(L1.NetworkFailed, 'L1 not notified');
      Check(L2.NetworkFailed, 'L2 not notified');
    finally
       Self.InviteAction.RemoveListener(L2);
       L2.Free;
    end;
  finally
     Self.InviteAction.RemoveListener(L1);
    L1.Free;
  end;
end;

procedure TestTIdSipInboundInvite.TestNotifyOfSuccess;
var
  Ack:    TIdSipRequest;
  L1, L2: TIdSipTestInboundInviteListener;
begin
  L1 := TIdSipTestInboundInviteListener.Create;
  try
    L2 := TIdSipTestInboundInviteListener.Create;
    try
      Self.InviteAction.AddListener(L1);
      Self.InviteAction.AddListener(L2);

      Self.InviteAction.Accept('', '');

      Ack := Self.InviteAction.InitialRequest.AckFor(Self.LastSentResponse);
      try
        Self.InviteAction.ReceiveRequest(Ack);
      finally
        Ack.Free;
      end;

      Check(L1.Succeeded, 'L1 not notified of action success');
      Check(L2.Succeeded, 'L2 not notified of action success');
    finally
       Self.InviteAction.RemoveListener(L2);
       L2.Free;
    end;
  finally
     Self.InviteAction.RemoveListener(L1);
    L1.Free;
  end;
end;

procedure TestTIdSipInboundInvite.TestReceiveResentAck;
var
  Ack:      TIdSipRequest;
  Listener: TIdSipTestInboundInviteListener;
begin
  Self.InviteAction.Accept('', '');

  Ack := Self.InviteAction.InitialRequest.AckFor(Self.LastSentResponse);
  try
    Self.InviteAction.ReceiveRequest(Ack);

    Listener := TIdSipTestInboundInviteListener.Create;
    try
      Self.InviteAction.AddListener(Listener);

      Self.InviteAction.ReceiveRequest(Ack);
      Check(not Listener.Succeeded, 'The InboundInvite renotified its listeners of success');
    finally
      Listener.Free;
    end;
  finally
    Ack.Free;
  end;
end;

procedure TestTIdSipInboundInvite.TestRedirectCall;
var
  Dest:         TIdSipAddressHeader;
  SentResponse: TIdSipResponse;
begin
  Self.MarkSentResponseCount;

  Dest := TIdSipAddressHeader.Create;
  try
    Dest.DisplayName := 'Wintermute';
    Dest.Address.Uri := 'sip:wintermute@talking-head.tessier-ashpool.co.luna';

    Self.InviteAction.Redirect(Dest);
    CheckResponseSent('No response sent');

    SentResponse := Self.LastSentResponse;
    CheckEquals(SIPMovedTemporarily,
                SentResponse.StatusCode,
                'Wrong response sent');
    Check(SentResponse.HasHeader(ContactHeaderFull),
          'No Contact header');
    CheckEquals(Dest.DisplayName,
                SentResponse.FirstContact.DisplayName,
                'Contact display name');
    CheckEquals(Dest.Address.Uri,
                SentResponse.FirstContact.Address.Uri,
                'Contact address');

    Check(Self.InviteAction.IsTerminated,
          'Action didn''t terminate');
  finally
    Dest.Free;
  end;
end;

procedure TestTIdSipInboundInvite.TestRedirectCallPermanent;
var
  Dest:         TIdSipAddressHeader;
  SentResponse: TIdSipResponse;
begin
  Self.MarkSentResponseCount;

  Dest := TIdSipAddressHeader.Create;
  try
    Dest.DisplayName := 'Wintermute';
    Dest.Address.Uri := 'sip:wintermute@talking-head.tessier-ashpool.co.luna';

    Self.InviteAction.Redirect(Dest, false);
    CheckResponseSent('No response sent');

    SentResponse := Self.LastSentResponse;
    CheckEquals(SIPMovedPermanently,
                SentResponse.StatusCode,
                'Wrong response sent');
    Check(SentResponse.HasHeader(ContactHeaderFull),
          'No Contact header');
    CheckEquals(Dest.DisplayName,
                SentResponse.FirstContact.DisplayName,
                'Contact display name');
    CheckEquals(Dest.Address.Uri,
                SentResponse.FirstContact.Address.Uri,
                'Contact address');

    Check(Self.InviteAction.IsTerminated,
          'Action didn''t terminate');
  finally
    Dest.Free;
  end;
end;

procedure TestTIdSipInboundInvite.TestRejectCallBusy;
var
  Response: TIdSipResponse;
begin
  Self.MarkSentResponseCount;
  Self.InviteAction.RejectCallBusy;
  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPBusyHere,
              Response.StatusCode,
              'Unexpected Status-Code');
  Check(Self.InviteAction.IsTerminated,
        'Action not terminated');
end;

procedure TestTIdSipInboundInvite.TestResendOk;
var
  Ack:        TIdSipRequest;
  I:          Integer;
  OriginalOk: TIdSipResponse;
begin
  // Does nothing if the Invite's not yet sent an OK
  Self.MarkSentResponseCount;
  Self.InviteAction.ResendOk;
  CheckNoResponseSent('The action sent an OK before it accepted the call');

  // Then we send an OK
  Self.InviteAction.Accept('', '');

  // And we make sure that repeated calls to ResendOk, well, resend the OK.
  OriginalOk := TIdSipResponse.Create;
  try
    OriginalOk.Assign(Self.LastSentResponse);

    for I := 1 to 2 do begin
      Self.MarkSentResponseCount;
      Self.InviteAction.ResendOk;

      CheckResponseSent(IntToStr(I) + ': Response not resent');
      CheckEquals(SIPOK,
                  Self.LastSentResponse.StatusCode,
                  IntToStr(I) + ': Unexpected response code');
      Check(OriginalOk.Equals(Self.LastSentResponse),
            IntToStr(I) + ': Unexpected OK');
    end;
  finally
    OriginalOk.Free;
  end;

  // But once we receive an ACK, we don't want to resend the OK.
  Ack := Self.Invite.AckFor(Self.LastSentResponse);
  try
    Self.InviteAction.ReceiveRequest(Ack);
  finally
    Ack.Free;
  end;

  Self.MarkSentResponseCount;
  Self.InviteAction.ResendOk;
  CheckNoResponseSent('The action sent an OK after it received an ACK');
end;

procedure TestTIdSipInboundInvite.TestRing;
var
  Response: TIdSipResponse;
begin
  Self.MarkSentResponseCount;
  Self.InviteAction.Ring;

  CheckResponseSent('No ringing response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPRinging,
              Response.StatusCode,
              'Unexpected Status-Code');
  Check(Response.ToHeader.HasTag,
        'To header doesn''t have tag');
  CheckEquals(Self.ToTag,
              Response.ToHeader.Tag,
              'To (local) tag');
end;

procedure TestTIdSipInboundInvite.TestSendSessionProgress;
begin
  Self.MarkSentResponseCount;
  Self.InviteAction.SendSessionProgress;

  CheckResponseSent('No session progress response sent');

  CheckEquals(SIPSessionProgress,
              Self.LastSentResponse.StatusCode,
              'Unexpected Status-Code');
end;

procedure TestTIdSipInboundInvite.TestTerminateAfterAccept;
begin
  // This should never happen, really. If you accept a call then InviteAction
  // terminates. Thus by calling Terminate you try to terminate an
  // already-terminated action - which should do nothing. In fact, the UA should
  // have already destroyed the action.

  Self.InviteAction.Accept('', '');

  Self.MarkSentResponseCount;
  Self.InviteAction.Terminate;

  CheckNoResponseSent('Response sent');
  Check(Self.InviteAction.IsTerminated,
        'Action not marked as terminated');
end;

procedure TestTIdSipInboundInvite.TestTerminateBeforeAccept;
begin
  Self.MarkSentResponseCount;

  Self.InviteAction.Terminate;

  CheckResponseSent('No response sent');

  CheckEquals(SIPRequestTerminated,
              Self.LastSentResponse.StatusCode,
              'Unexpected Status-Code');

  Check(Self.InviteAction.IsTerminated,
        'Action not marked as terminated');
end;

procedure TestTIdSipInboundInvite.TestTimeOut;
begin
  Self.MarkSentResponseCount;

  Self.InviteAction.TimeOut;

  CheckResponseSent('No response sent');

  CheckEquals(SIPRequestTerminated,
              Self.LastSentResponse.StatusCode,
              'Unexpected Status-Code');

  Check(Self.InviteAction.IsTerminated,
        'Action not marked as terminated');
  Check(Self.Failed,
        'Listeners not notified of failure');
end;

//******************************************************************************
//* TestTIdSipOutboundInvite                                                   *
//******************************************************************************
//* TestTIdSipOutboundInvite Public methods ************************************

procedure TestTIdSipOutboundInvite.SetUp;
begin
  inherited SetUp;

  Self.Core.AddUserAgentListener(Self);

  // We create Self.Dialog in Self.OnDialogEstablished

  Self.DroppedUnmatchedResponse := false;
  Self.InviteMimeType           := SdpMimeType;
  Self.InviteOffer              := TIdSipTestResources.BasicSDP('1.2.3.4');
  Self.OnCallProgressFired      := false;
  Self.OnDialogEstablishedFired := false;
  Self.OnFailureFired           := false;
  Self.OnRedirectFired          := false;
  Self.OnSuccessFired           := false;
end;

procedure TestTIdSipOutboundInvite.TearDown;
begin
  Self.Dialog.Free;

  inherited TearDown;
end;

//* TestTIdSipOutboundInvite Protected methods *********************************

function TestTIdSipOutboundInvite.CreateAction: TIdSipAction;
var
  Invite: TIdSipOutboundInitialInvite;
begin
  Result := Self.Core.AddOutboundAction(TIdSipOutboundInitialInvite);

  Invite := Result as TIdSipOutboundInitialInvite;
  Invite.Destination := Self.Destination;
  Invite.MimeType    := Self.InviteMimeType;
  Invite.Offer       := Self.InviteOffer;
  Invite.AddListener(Self);
  Invite.Send;
end;

function TestTIdSipOutboundInvite.CreateInitialInvite: TIdSipOutboundInitialInvite;
begin
  Result := Self.Core.AddOutboundAction(TIdSipOutboundInitialInvite) as TIdSipOutboundInitialInvite;
  Result.Destination := Self.Destination;
  Result.MimeType    := Self.InviteMimeType;
  Result.Offer       := Self.InviteOffer;
  Result.Send;
end;

//* TestTIdSipOutboundInvite Private methods ***********************************

procedure TestTIdSipOutboundInvite.CheckReceiveFailed(StatusCode: Cardinal);
var
  InviteCount: Integer;
begin
  Self.CreateAction;

  InviteCount := Self.Core.CountOf(MethodInvite);
  Self.ReceiveResponse(StatusCode);

  Check(Self.OnFailureFired,
        'OnFailure didn''t fire after receiving a '
      + IntToStr(StatusCode) + ' response');
  Check(Self.Core.CountOf(MethodInvite) < InviteCount,
        'Invite action not destroyed after receiving a '
      + IntToStr(StatusCode) + ' response');
end;

procedure TestTIdSipOutboundInvite.CheckReceiveOk(StatusCode: Cardinal);
begin
  Self.CreateAction;
  Self.ReceiveResponse(StatusCode);

  Check(Self.OnSuccessFired,
        'OnSuccess didn''t fire after receiving a '
      + IntToStr(StatusCode) + ' response');
end;

procedure TestTIdSipOutboundInvite.CheckReceiveProvisional(StatusCode: Cardinal);
begin
  Self.CreateAction;
  Self.ReceiveResponse(StatusCode);

  Check(Self.OnCallProgressFired,
        'OnCallProgress didn''t fire after receiving a '
      + IntToStr(StatusCode) + ' response');
end;

procedure TestTIdSipOutboundInvite.CheckReceiveRedirect(StatusCode: Cardinal);
begin
  Self.CreateAction;

  Self.ReceiveResponse(StatusCode);

  Check(Self.OnRedirectFired,
        'OnRedirect didn''t fire after receiving a '
      + IntToStr(StatusCode) + ' response');
end;

function TestTIdSipOutboundInvite.CreateArbitraryDialog: TIdSipDialog;
var
  Response: TIdSipResponse;
begin
  Self.Invite.RequestUri := Self.Destination.Address;
  Response := Self.Core.CreateResponse(Self.Invite, SIPOK);
  try
    Result := TIdSipDialog.CreateInboundDialog(Self.Invite, Response, false);
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipOutboundInvite.OnAuthenticationChallenge(UserAgent: TIdSipAbstractUserAgent;
                                                             Challenge: TIdSipResponse;
                                                             var Username: String;
                                                             var Password: String;
                                                             var TryAgain: Boolean);
begin
  // Unused: do nothing
end;

procedure TestTIdSipOutboundInvite.OnCallProgress(InviteAgent: TIdSipOutboundInvite;
                                                  Response: TIdSipResponse);
begin
  Self.OnCallProgressFired := true;
end;

procedure TestTIdSipOutboundInvite.OnDialogEstablished(InviteAgent: TIdSipOutboundInvite;
                                                       NewDialog: TidSipDialog);
begin
  Self.Dialog := NewDialog.Copy;
  InviteAgent.Dialog := Self.Dialog;

  Self.OnDialogEstablishedFired := true;
  Self.ToHeaderTag := NewDialog.ID.RemoteTag;
end;

procedure TestTIdSipOutboundInvite.OnDroppedUnmatchedMessage(UserAgent: TIdSipAbstractUserAgent;
                                                             Message: TIdSipMessage;
                                                             Receiver: TIdSipTransport);
begin
  Self.DroppedUnmatchedResponse := true;
end;

procedure TestTIdSipOutboundInvite.OnFailure(InviteAgent: TIdSipOutboundInvite;
                                             Response: TIdSipResponse;
                                             const Reason: String);
begin
  Self.OnFailureFired := true;
end;

procedure TestTIdSipOutboundInvite.OnInboundCall(UserAgent: TIdSipUserAgent;
                                                 Session: TIdSipInboundSession);
begin
  // Unused: do nothing
end;

procedure TestTIdSipOutboundInvite.OnRedirect(Invite: TIdSipOutboundInvite;
                                              Response: TIdSipResponse);
begin
  Self.OnRedirectFired := true;
end;

procedure TestTIdSipOutboundInvite.OnSuccess(InviteAgent: TIdSipOutboundInvite;
                                             Response: TIdSipResponse);
begin
  Self.OnSuccessFired := true;
end;

//* TestTIdSipOutboundInvite Published methods *********************************

procedure TestTIdSipOutboundInvite.TestAddListener;
var
  L1, L2: TIdSipTestInviteListener;
  Invite: TIdSipOutboundInvite;
begin
  Self.MarkSentRequestCount;
  Invite := Self.CreateAction as TIdSipOutboundInvite;
  CheckRequestSent(Invite.ClassName + ': No INVITE sent');

  L1 := TIdSipTestInviteListener.Create;
  try
    L2 := TIdSipTestInviteListener.Create;
    try
      Invite.AddListener(L1);
      Invite.AddListener(L2);

      Self.ReceiveOk(Self.LastSentRequest);

      Check(L1.Success, 'L1 not informed of success');
      Check(L2.Success, 'L2 not informed of success');
    finally
      L2.Free;
    end;
  finally
    L1.Free;
  end;
end;

procedure TestTIdSipOutboundInvite.TestAnswerInAck;
var
  Invite: TIdSipOutboundInvite;
begin
  //  ---       INVITE        --->
  // <--- 200 OK (with offer) ---
  //  ---  ACK (with answer)  --->

  Self.InviteOffer    := '';
  Self.InviteMimeType := '';
  Invite := Self.CreateAction as TIdSipOutboundInvite;

  // Sanity check
  CheckEquals('',
              Self.LastSentRequest.Body,
              'You just sent an INVITE with a body!');

  Invite.Offer    := TIdSipTestResources.BasicSDP('1.2.3.4');
  Invite.MimeType := SdpMimeType;

  Self.MarkSentAckCount;
  Self.ReceiveOkWithBody(Invite.InitialRequest,
                         TIdSipTestResources.BasicSDP('4.3.2.1'),
                         Invite.MimeType);

  CheckAckSent('No ACK sent');
  CheckEquals(Invite.Offer,
              Self.LastSentAck.Body,
              'Incorrect answer');
  CheckEquals(Invite.MimeType,
              Self.LastSentAck.ContentType,
              'Incorrect answer type');
end;

procedure TestTIdSipOutboundInvite.TestCancelAfterAccept;
var
  OutboundInvite: TIdSipOutboundInvite;
begin
  OutboundInvite := Self.CreateAction as TIdSipOutboundInvite;

  Self.ReceiveOk(Self.LastSentRequest);

  Self.MarkSentRequestCount;

  OutboundInvite.Cancel;

  CheckNoRequestSent('Action sent a CANCEL for a fully established call');
end;

procedure TestTIdSipOutboundInvite.TestCancelBeforeAccept;
var
  Invite:            TIdSipRequest;
  InviteCount:       Integer;
  OutboundInvite:    TIdSipOutboundInvite;
  RequestTerminated: TIdSipResponse;
begin
  //  ---         INVITE         --->
  // <---       180 Ringing      ---
  //  ---         CANCEL         --->
  // <---         200 OK         ---  (for the CANCEL)
  // <--- 487 Request Terminated ---  (for the INVITE)
  //  ---           ACK          --->

  //  ---         INVITE         --->
  OutboundInvite := Self.CreateAction as TIdSipOutboundInvite;

  InviteCount := Self.Core.CountOf(MethodInvite);
  Invite := TIdSipRequest.Create;
  try
    Invite.Assign(Self.LastSentRequest);
    // Note that Invite's To header has no tag because we haven't established
    // a dialog.
    RequestTerminated := TIdSipResponse.InResponseTo(Invite, SIPRequestTerminated);
    try
      // <---       180 Ringing      ---
      Self.ReceiveRinging(Invite);

      Check(Self.OnDialogEstablishedFired,
            'No dialog established');

      // Now that we have established a dialog, the Request Terminated response
      // will contain that dialog ID.
      RequestTerminated.ToHeader.Tag := Self.ToHeaderTag;

      Self.MarkSentRequestCount;

      //  ---         CANCEL         --->
      OutboundInvite.Cancel;

      CheckRequestSent('No CANCEL sent');
      CheckEquals(MethodCancel,
                  Self.LastSentRequest.Method,
                  'The request sent wasn''t a CANCEL');
      Check(not OutboundInvite.IsTerminated,
            'No Request Terminated received means no termination');

      // <---         200 OK         ---  (for the CANCEL)
      Self.ReceiveOk(Self.LastSentRequest);

      // <--- 487 Request Terminated ---  (for the INVITE)
      //  ---           ACK          --->
      Self.MarkSentACKCount;
      Self.ReceiveResponse(RequestTerminated);

      CheckAckSent('No ACK sent');

      Check(Self.Core.CountOf(MethodInvite) < InviteCount,
            'Action not terminated');
    finally
      RequestTerminated.Free;
    end;
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipOutboundInvite.TestCancelBeforeProvisional;
var
  Invite:            TIdSipRequest;
  InviteCount:       Integer;
  OutboundInvite:    TIdSipOutboundInvite;
  RequestTerminated: TIdSipResponse;
begin
  //  ---         INVITE         --->
  //  (UAC initiates cancel, but no provisional response = don't send CANCEL yet.)
  // <---       180 Ringing      ---
  // (Ah! A provisional response! Let's send that pending CANCEL)
  //  ---         CANCEL         --->
  // <---         200 OK         ---  (for the CANCEL)
  // <--- 487 Request Terminated ---  (for the INVITE)
  //  ---           ACK          --->

  //  ---         INVITE         --->
  OutboundInvite := Self.CreateAction as TIdSipOutboundInvite;

  InviteCount := Self.Core.CountOf(MethodInvite);
  Invite := TIdSipRequest.Create;
  try
    Invite.Assign(Self.LastSentRequest);
    // Note that Invite's To header has no tag because we haven't established
    // a dialog. Therefore the RequestTerminated won't match the INVITE's
    // dialog - we have to wait until the action receives the 180 Ringing before
    // we can set the To tag.
    RequestTerminated := TIdSipResponse.InResponseTo(Invite, SIPRequestTerminated);
    try
      Self.MarkSentRequestCount;

      OutboundInvite.Cancel;

      CheckNoRequestSent('CANCEL sent before the session receives a '
                       + 'provisional response');

      Check(not OutboundInvite.IsTerminated,
            'No Request Terminated received means no termination');

     // <---       180 Ringing      ---
     //  ---         CANCEL         --->
     Self.ReceiveRinging(Self.LastSentRequest);
     Check(Self.OnDialogEstablishedFired,
           'No dialog established');
     // Now that we have the remote tag we can:
     RequestTerminated.ToHeader.Tag := Self.ToHeaderTag;

      // <---         200 OK         ---  (for the CANCEL)
      Self.ReceiveOk(Self.LastSentRequest);

      // <--- 487 Request Terminated ---  (for the INVITE)
      //  ---           ACK          --->

      Self.MarkSentACKCount;
      Self.ReceiveResponse(RequestTerminated);

      CheckAckSent('No ACK sent');

      Check(Self.Core.CountOf(MethodInvite) < InviteCount,
            'Action not terminated');
    finally
      RequestTerminated.Free;
    end;
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipOutboundInvite.TestCancelReceiveInviteOkBeforeCancelOk;
var
  Action: TIdSipOutboundInvite;
  Cancel: TIdSipRequest;
  Invite: TIdSipRequest;
begin
  //  ---          INVITE         --->
  // <---        100 Trying       ---
  //  ---          CANCEL         --->
  // <--- 200 OK (for the INVITE) ---
  //  ---           ACK           --->
  // <--- 200 OK (for the CANCEL) ---
  //  ---           BYE           --->
  // <---   200 OK (for the BYE)  ---

  Action := Self.CreateAction as TIdSipOutboundInvite;

  Invite := TIdSipRequest.Create;
  try
    Cancel := TIdSipRequest.Create;
    try
      Invite.Assign(Self.LastSentRequest);
      Self.ReceiveTrying(Invite);

      Action.Cancel;
      Cancel.Assign(Self.LastSentRequest);

      Self.MarkSentAckCount;
      Self.MarkSentRequestCount;
      Self.ReceiveOk(Invite);
      Self.ReceiveOk(Cancel);

      CheckRequestSent('No request sent to terminate the cancelled session');
      CheckEquals(MethodBye,
                  Self.LastSentRequest.Method,
                  'Terminating request');

      CheckAckSent('No ACK sent in response to the 2xx');
      CheckEquals(Invite.Body,
                  Self.LastSentAck.Body,
                  'ACK body');
      CheckEquals(Invite.ContentType,
                  Self.LastSentAck.ContentType,
                  'ACK Content-Type');
      Check(Invite.ContentDisposition.Equals(Self.LastSentAck.ContentDisposition),
            'ACK Content-Disposition');
    finally
      Cancel.Free;
    end;
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipOutboundInvite.TestInviteTwice;
var
  Invite: TIdSipAction;
begin
  Invite := Self.CreateAction;

  try
    Invite.Send;
    Fail('Failed to bail out calling Invite a 2nd time');
  except
    on EIdSipTransactionUser do;
  end;
end;

procedure TestTIdSipOutboundInvite.TestIsInvite;
begin
  Check(Self.CreateAction.IsInvite, 'INVITE action not marked as such');
end;

procedure TestTIdSipOutboundInvite.TestMethod;
begin
  CheckEquals(MethodInvite,
              TIdSipOutboundInvite.Method,
              'Outbound INVITE Method');
end;

procedure TestTIdSipOutboundInvite.TestOfferInInvite;
begin
  //  ---    INVITE (with offer)   --->
  // <---   200 OK (with answer)   ---
  //  --- ACK (with copy of offer) --->

  Self.MarkSentRequestCount;
  Self.CreateAction;
  CheckRequestSent('No initial INVITE sent');

  CheckEquals(Self.InviteOffer,
              Self.LastSentRequest.Body,
              'Body of INVITE');
  CheckEquals(Self.InviteMimeType,
              Self.LastSentRequest.ContentType,
              'Content-Type of INVITE');

  Self.MarkSentAckCount;
  Self.ReceiveOkWithBody(Self.LastSentRequest,
                         TIdSipTestResources.BasicSDP('4.3.2.1'),
                         SdpMimeType);

  CheckAckSent('No ACK sent');
  CheckEquals(Self.LastSentRequest.Body,
              Self.LastSentAck.Body,
              'Body of ACK doesn''t match INVITE');
  CheckEquals(Self.LastSentRequest.ContentType,
              Self.LastSentAck.ContentType,
              'Content-Type of ACK doesn''t match INVITE');
end;

procedure TestTIdSipOutboundInvite.TestReceive2xxSchedulesTransactionCompleted;
var
  Invite: TIdSipAction;
begin
  // RFC 3261, section 13.2.2.4 says
  //   The UAC core considers the INVITE transaction completed 64*T1 seconds
  //   after the reception of the first 2xx response.  At this point all the
  //   early dialogs that have not transitioned to established dialogs are
  //   terminated.  Once the INVITE transaction is considered completed by
  //   the UAC core, no more new 2xx responses are expected to arrive.
  //
  // This test makes sure we don't schedule this when we send the INVITE.

  Invite := Self.CreateAction;
  Self.DebugTimer.TriggerAllEventsOfType(TIdSipActionsWait);

  Check(not Invite.IsTerminated,
        'OutboundInvite terminated prematurely: it incorrectly scheduled '
      + 'a TIdSipOutboundInviteTransactionComplete');

  Self.ReceiveOk(Self.LastSentRequest);

  Self.DebugTimer.TriggerAllEventsOfType(TIdSipActionsWait);

  Check(Invite.IsTerminated,
        'OutboundInvite didn''t schedule a TIdSipOutboundInviteTransactionComplete');
end;

procedure TestTIdSipOutboundInvite.TestReceiveProvisional;
var
  StatusCode: Integer;
begin
  StatusCode := SIPLowestProvisionalCode;
//  for StatusCode := SIPLowestProvisionalCode to SIPHighestProvisionalCode do
    Self.CheckReceiveProvisional(StatusCode);
end;

procedure TestTIdSipOutboundInvite.TestReceiveGlobalFailed;
var
  StatusCode: Integer;
begin
  StatusCode := SIPLowestGlobalFailureCode;
//  for StatusCode := SIPLowestGlobalFailureCode to SIPHighestGlobalFailureCode do
    Self.CheckReceiveFailed(StatusCode);
end;

procedure TestTIdSipOutboundInvite.TestReceiveOk;
var
  StatusCode: Integer;
begin
  StatusCode := SIPLowestOkCode;
//  for StatusCode := SIPLowestOkCode to SIPHighestOkCode do
    Self.CheckReceiveOk(StatusCode);
end;

procedure TestTIdSipOutboundInvite.TestReceiveRedirect;
var
  StatusCode: Integer;
begin
  StatusCode := SIPLowestRedirectionCode;
//  for StatusCode := SIPLowestRedirectionCode to SIPHighestRedirectionCode do
    Self.CheckReceiveRedirect(StatusCode);
end;

procedure TestTIdSipOutboundInvite.TestReceiveRequestFailed;
var
  StatusCode: Integer;
begin
  StatusCode := SIPLowestFailureCode;

//  for StatusCode := SIPLowestFailureCode to SIPUnauthorized - 1 do
    Self.CheckReceiveFailed(StatusCode);
{
  for StatusCode := SIPUnauthorized + 1 to SIPProxyAuthenticationRequired - 1 do
    Self.CheckReceiveFailed(StatusCode);

  for StatusCode := SIPProxyAuthenticationRequired + 1 to SIPHighestFailureCode do
    Self.CheckReceiveFailed(StatusCode);
}
end;

procedure TestTIdSipOutboundInvite.TestReceiveRequestFailedAfterAckSent;
var
  InviteRequest: TIdSipRequest;
begin
  //  ---          INVITE         --->
  // <---          200 OK         ---
  //  ---           ACK           --->
  // <--- 503 Service Unavailable ---

  // This situation should never arise: the remote end's sending a failure
  // response to a request it has already accepted. Still, I've seen it happen
  // once before...

  Self.CreateAction;

  InviteRequest := TIdSipRequest.Create;
  try
    InviteRequest.Assign(Self.LastSentRequest);

    Self.MarkSentAckCount;
    Self.ReceiveOk(InviteRequest);
    CheckAckSent('No ACK sent');

    Self.ReceiveServiceUnavailable(InviteRequest);

    Check(Self.DroppedUnmatchedResponse,
          'Invite action didn''t terminate, so the Transaction-User core '
        + 'didn''t drop the message');
  finally
    InviteRequest.Free;
  end;
end;

procedure TestTIdSipOutboundInvite.TestReceiveServerFailed;
var
  StatusCode: Integer;
begin
  StatusCode := SIPLowestServerFailureCode;
//  for StatusCode := SIPLowestServerFailureCode to SIPHighestServerFailureCode do
    Self.CheckReceiveFailed(StatusCode);
end;

procedure TestTIdSipOutboundInvite.TestRemoveListener;
var
  L1, L2: TIdSipTestInviteListener;
  Invite: TIdSipOutboundInvite;
begin
  Invite := Self.CreateAction as TIdSipOutboundInvite;

  L1 := TIdSipTestInviteListener.Create;
  try
    L2 := TIdSipTestInviteListener.Create;
    try
      Invite.AddListener(L1);
      Invite.AddListener(L2);
      Invite.RemoveListener(L2);

      Self.ReceiveOk(Self.LastSentRequest);

      Check(L1.Success,
            'First listener not notified');
      Check(not L2.Success,
            'Second listener erroneously notified, ergo not removed');
    finally
      L2.Free
    end;
  finally
    L1.Free;
  end;
end;

procedure TestTIdSipOutboundInvite.TestSendTwice;
var
  Invite: TIdSipAction;
begin
  Invite := Self.CreateAction;
  try
    Invite.Send;
    Fail(Invite.ClassName + ': Failed to bail out calling Send a 2nd time');
  except
    on EIdSipTransactionUser do;
  end;
end;

procedure TestTIdSipOutboundInvite.TestTerminateBeforeAccept;
var
  OutboundInvite: TIdSipOutboundInvite;
begin
  OutboundInvite := Self.CreateAction as TIdSipOutboundInvite;
  Self.ReceiveRinging(Self.LastSentRequest);
  Self.MarkSentRequestCount;

  OutboundInvite.Terminate;

  CheckRequestSent('Action didn''t send a CANCEL');
end;

procedure TestTIdSipOutboundInvite.TestTerminateAfterAccept;
var
  OutboundInvite: TIdSipOutboundInvite;
begin
  OutboundInvite := Self.CreateAction as TIdSipOutboundInvite;

  Self.ReceiveOk(Self.LastSentRequest);

  Self.MarkSentRequestCount;

  OutboundInvite.Terminate;

  CheckNoRequestSent('Action sent a CANCEL for a fully established call');
end;

procedure TestTIdSipOutboundInvite.TestTransactionCompleted;
var
  Invite: TIdSipOutboundInvite;
begin
  Invite := Self.CreateAction as TIdSipOutboundInvite;
  Invite.TransactionCompleted;
  Check(Invite.IsTerminated, 'Outbound INVITE not marked as terminated');
end;

//******************************************************************************
//* TestTIdSipOutboundRedirectedInvite                                         *
//******************************************************************************
//* TestTIdSipOutboundRedirectedInvite Protected methods ***********************

function TestTIdSipOutboundRedirectedInvite.CreateAction: TIdSipAction;
begin
  Self.CreateInitialInvite;
  Result := Self.CreateInvite;
end;

//* TestTIdSipOutboundRedirectedInvite Private methods *************************

function TestTIdSipOutboundRedirectedInvite.CreateInvite: TIdSipOutboundRedirectedInvite;
begin
  Result := Self.Core.AddOutboundAction(TIdSipOutboundRedirectedInvite) as TIdSipOutboundRedirectedInvite;
  Result.Contact        := Self.Destination;
  Result.OriginalInvite := Self.LastSentRequest;
  Result.AddListener(Self);
  Result.Send;
end;

//* TestTIdSipOutboundRedirectedInvite Published methods ***********************

procedure TestTIdSipOutboundRedirectedInvite.TestRedirectedInvite;
var
  Invite:         TIdSipOutboundRedirectedInvite;
  NewInvite:      TIdSipRequest;
  OriginalInvite: TIdSipRequest;
begin
  OriginalInvite := TIdSipRequest.Create;
  try
    Self.CreateInitialInvite;
    OriginalInvite.Assign(Self.LastSentRequest);

    Self.MarkSentRequestCount;

    Invite := Self.CreateInvite;

    CheckRequestSent('No INVITE sent');

    NewInvite := Invite.InitialRequest;

    CheckEquals(OriginalInvite.CallID,
                NewInvite.CallID,
                'Call-ID mismatch between original and new INVITEs');
    CheckEquals(OriginalInvite.From.Tag,
                NewInvite.From.Tag,
                'From tag mismatch between original and new INVITEs');
    Check(not NewInvite.ToHeader.HasTag,
          'New INVITE mustn''t have a To tag');
  finally
    OriginalInvite.Free;
  end;
end;

//******************************************************************************
//* TestTIdSipOutboundReInvite                                                 *
//******************************************************************************
//* TestTIdSipOutboundReInvite Public methods **********************************

procedure TestTIdSipOutboundReInvite.SetUp;
begin
  inherited SetUp;

  Self.Dialog := Self.CreateArbitraryDialog;
end;

procedure TestTIdSipOutboundReInvite.TearDown;
begin
  Self.Dialog.Free;

  inherited TearDown;
end;

//* TestTIdSipOutboundReInvite Protected methods *******************************

function TestTIdSipOutboundReInvite.CreateAction: TIdSipAction;
var
  Invite: TIdSipOutboundReInvite;
begin
  Self.Dialog.RemoteTarget.Uri := Self.Destination.Address.Uri;

  Invite := Self.CreateInvite;
  Invite.Dialog         := Self.Dialog;
  Invite.MimeType       := Self.InviteMimeType;
  Invite.Offer          := Self.InviteOffer;
  Invite.OriginalInvite := Self.Invite;
  Invite.AddListener(Self);
  Invite.Send;

  Result := Invite;
end;

//* TestTIdSipOutboundReInvite Private methods *********************************

function TestTIdSipOutboundReInvite.CreateInvite: TIdSipOutboundReInvite;
begin
  Result := Self.Core.AddOutboundAction(TIdSipOutboundReInvite) as TIdSipOutboundReInvite;
end;

//******************************************************************************
//* TestTIdSipSession                                                          *
//******************************************************************************
//* TestTIdSipSession Public methods *******************************************

procedure TestTIdSipSession.SetUp;
begin
  inherited SetUp;

  Self.Module := Self.Core.ModuleFor(MethodInvite) as TIdSipInviteModule;

  Self.MultiStreamSdp := Self.CreateMultiStreamSdp;
  Self.SimpleSdp      := Self.CreateSimpleSdp;

  Self.MimeType                  := '';
  Self.OnEndedSessionFired       := false;
  Self.OnEstablishedSessionFired := false;
  Self.OnModifiedSessionFired    := false;
  Self.OnModifySessionFired      := false;
  Self.RemoteSessionDescription  := '';
end;

procedure TestTIdSipSession.TearDown;
begin
  Self.SimpleSdp.Free;
  Self.MultiStreamSdp.Free;

  inherited TearDown;
end;

//* TestTIdSipSession Protected methods ****************************************

procedure TestTIdSipSession.CheckResendWaitTime(Milliseconds: Cardinal;
                                                const Msg: String);
begin
  Check(Milliseconds mod 10 = 0, Msg);
end;

function TestTIdSipSession.CreateAndEstablishSession: TIdSipSession;
var
  NewSession: TIdSipSession;
begin
  NewSession := Self.CreateAction as TIdSipSession;
  Self.EstablishSession(NewSession);

  Result := NewSession;
end;

function TestTIdSipSession.CreateMultiStreamSdp: TIdSdpPayload;
var
  Connection: TIdSdpConnection;
  MD:         TIdSdpMediaDescription;
begin
  Result := TIdSdpPayload.Create;
  Result.Version                := 0;

  Result.Origin.Username        := 'wintermute';
  Result.Origin.SessionID       := '2890844526';
  Result.Origin.SessionVersion  := '2890842807';
  Result.Origin.NetType         := Id_SDP_IN;
  Result.Origin.AddressType     := Id_IPv4;
  Result.Origin.Address         := '127.0.0.1';

  Result.SessionName            := 'Minimum Session Info';

  Connection := Result.AddConnection;
  Connection.NetType     := Id_SDP_IN;
  Connection.AddressType := Id_IPv4;
  Connection.Address     := '127.0.0.1';

  MD := Result.AddMediaDescription;
  MD.MediaType := mtAudio;
  MD.Port      := 10000;
  MD.Transport := AudioVisualProfile;
  MD.AddFormat('0');

  MD := Result.AddMediaDescription;
  MD.MediaType := mtText;
  MD.Port      := 11000;
  MD.Transport := AudioVisualProfile;
  MD.AddFormat('98');
  MD.AddAttribute(RTPMapAttribute, '98 t140/1000');
end;

function TestTIdSipSession.CreateRemoteReInvite(LocalDialog: TIdSipDialog): TIdSipRequest;
begin
  Result := Self.Module.CreateReInvite(LocalDialog,
                                       Self.SimpleSdp.AsString,
                                       Self.SimpleSdp.MimeType);
  try
    Result.ToHeader.Tag    := LocalDialog.ID.LocalTag;
    Result.From.Tag        := LocalDialog.ID.RemoteTag;
    Result.CSeq.SequenceNo := LocalDialog.RemoteSequenceNo + 1;
  except
    FreeAndNil(Result);

    raise;
  end;
end;

function TestTIdSipSession.CreateSimpleSdp: TIdSdpPayload;
var
  Connection: TIdSdpConnection;
  MD:         TIdSdpMediaDescription;
begin
  Result := TIdSdpPayload.Create;
  Result.Version               := 0;

  Result.Origin.Username       := 'wintermute';
  Result.Origin.SessionID      := '2890844526';
  Result.Origin.SessionVersion := '2890842807';
  Result.Origin.NetType        := Id_SDP_IN;
  Result.Origin.AddressType    := Id_IPv4;
  Result.Origin.Address        := '127.0.0.1';

  Result.SessionName           := 'Minimum Session Info';

  MD := Result.AddMediaDescription;
  MD.MediaType := mtText;
  MD.Port      := 11000;
  MD.Transport := AudioVisualProfile;
  MD.AddFormat('98');
  MD.AddAttribute(RTPMapAttribute, '98 t140/1000');

  MD.Connections.Add(TIdSdpConnection.Create);
  Connection := MD.Connections[0];
  Connection.NetType     := Id_SDP_IN;
  Connection.AddressType := Id_IPv4;
  Connection.Address     := '127.0.0.1';
end;

procedure TestTIdSipSession.OnEndedSession(Session: TIdSipSession;
                                           ErrorCode: Cardinal;
                                           const Reason: String);
begin
  Self.OnEndedSessionFired := true;
  Self.ErrorCode           := ErrorCode;
  Self.Reason              := Reason;
end;

procedure TestTIdSipSession.OnEstablishedSession(Session: TIdSipSession;
                                                 const RemoteSessionDescription: String;
                                                 const MimeType: String);
begin
  Self.OnEstablishedSessionFired := true;
end;

procedure TestTIdSipSession.OnModifiedSession(Session: TIdSipSession;
                                              Answer: TIdSipResponse);
begin
  Self.OnModifiedSessionFired := true;

  Self.RemoteSessionDescription := Answer.Body;
  Self.MimeType                 := Answer.ContentType;
end;

procedure TestTIdSipSession.OnModifySession(Session: TIdSipSession;
                                            const RemoteSessionDescription: String;
                                            const MimeType: String);
begin
  Self.OnModifySessionFired := true;

  Self.RemoteSessionDescription := RemoteSessionDescription;
  Self.MimeType                 := MimeType;
end;

procedure TestTIdSipSession.OnProgressedSession(Session: TIdSipSession;
                                                Progress: TIdSipResponse);
begin
  // Do nothing.
end;

procedure TestTIdSipSession.ReceiveRemoteReInvite(Session: TIdSipSession);
begin
  // At this point Self.Invite represents the INVITE we sent out
  Self.Invite.LastHop.Branch  := Self.Invite.LastHop.Branch + '1';
  Self.Invite.CallID          := Session.Dialog.ID.CallID;
  Self.Invite.From.Tag        := Session.Dialog.ID.RemoteTag;
  Self.Invite.ToHeader.Tag    := Session.Dialog.ID.LocalTag;
  Self.Invite.CSeq.SequenceNo := Session.Dialog.RemoteSequenceNo + 1;

  Self.Invite.Body          := Self.RemoteSessionDescription;
  Self.Invite.ContentType   := Self.MimeType;
  Self.Invite.ContentLength := Length(Self.Invite.Body);

  // Now it represents an INVITE received from the network
  Self.ReceiveInvite;
end;

//* TestTIdSipSession Published methods ****************************************

procedure TestTIdSipSession.TestAckToInDialogInviteMatchesInvite;
var
  Ack:     TIdSipRequest;
  Session: TIdSipSession;
begin
  Session := Self.CreateAndEstablishSession;
  Self.ReceiveRemoteReInvite(Session);

  Check(Self.OnModifySessionFired
        Session.ClassName + ': OnModifySession didn''t fire');

  Session.AcceptModify('', '');

  // The last request was the inbound re-INVITE.
  Ack := Self.Dispatcher.Transport.LastRequest.AckFor(Self.LastSentResponse);
  try
    Check(not Session.Match(Ack),
          Session.ClassName + ': ACK mustn''t match the Session');
  finally
    Ack.Free;
  end;
end;

procedure TestTIdSipSession.TestDontMatchResponseToModify;
var
  Ok:      TIdSipResponse;
  Session: TIdSipSession;
begin
  Session := Self.CreateAction as TIdSipSession;
  Self.EstablishSession(Session);
  Check(Session.DialogEstablished,
        Session.ClassName + ': No dialog established');
  Session.Modify('', '');

  Ok := TIdSipResponse.InResponseTo(Self.LastSentRequest,
                                    SIPOK);
  try
    Check(not Session.Match(Ok),
          Session.ClassName + ': Responses to outbound re-INVITEs must only '
        + 'match the OutboundInvites');
  finally
    Ok.Free;
  end;
end;

procedure TestTIdSipSession.TestDontMatchResponseToInitialRequest;
var
  Ok:      TIdSipResponse;
  Session: TIdSipSession;
begin
  Session := Self.CreateAction as TIdSipSession;

  Ok := TIdSipResponse.InResponseTo(Session.InitialRequest, SIPOK);
  try
    Ok.ToHeader.Tag := Self.Core.NextTag; // Just for completeness' sake
    Check(not Session.Match(Ok),
          Session.ClassName + ': Responses to the initial INVITE must only '
        + 'match the (In|Out)boundInvite');
  finally
    Ok.Free;
  end;
end;

procedure TestTIdSipSession.TestInboundModify;
var
  LocalSessionDescription: String;
  LocalMimeType:           String;
  Session:                 TIdSipSession;
begin
  Session := Self.CreateAction as TIdSipSession;
  Self.EstablishSession(Session);

  LocalMimeType                 := SdpMimeType;
  LocalSessionDescription       := Format(DummySDP, ['127.0.0.1']);
  Self.MimeType                 := SdpMimeType;
  Self.RemoteSessionDescription := Self.SimpleSdp.AsString;

  Self.ReceiveRemoteReInvite(Session);
  Session.AcceptModify(LocalSessionDescription, LocalMimeType);
  Self.ReceiveAck;

  Check(Self.OnModifySessionFired,
        Session.ClassName + ': OnModifySession didn''t fire');
  CheckEquals(MimeType,
              Session.LocalMimeType,
              'Session.LocalMimeType');
  CheckEquals(LocalSessionDescription,
              Session.LocalSessionDescription,
              'Session.LocalSessionDescription');
  CheckEquals(Self.MimeType,
              Session.RemoteMimeType,
              'Session.RemoteMimeType');
  CheckEquals(Self.RemoteSessionDescription,
              Session.RemoteSessionDescription,
              'Session.RemoteSessionDescription');
end;

procedure TestTIdSipSession.TestIsSession;
var
  Action: TIdSipAction;
begin
  Action := Self.CreateAction;
  // Self.UA owns the action!
  Check(Action.IsSession,
        Action.ClassName + ' not marked as a Session');
end;

procedure TestTIdSipSession.TestMatchBye;
var
  Bye:     TIdSipRequest;
  Session: TIdSipSession;
begin
  Session := Self.CreateAction as TIdSipSession;
  Self.EstablishSession(Session);
  Check(Session.DialogEstablished,
        Session.ClassName + ': No dialog established');

  Bye := Self.CreateRemoteReInvite(Session.Dialog);
  try
    Bye.Method := MethodBye;

    Check(Session.Match(Bye),
          Session.ClassName + ': BYE must match session');
  finally
    Bye.Free;
  end;
end;

procedure TestTIdSipSession.TestMatchInitialRequest;
var
  Session: TIdSipSession;
begin
  Session := Self.CreateAction as TIdSipSession;

  Check(not Session.Match(Session.InitialRequest),
        Session.ClassName + ': The initial INVITE must only match the '
      + '(In|Out)boundInvite');
end;

procedure TestTIdSipSession.TestMatchInboundModify;
var
  ReInvite: TIdSipRequest;
  Session:  TIdSipSession;
begin
  Session := Self.CreateAction as TIdSipSession;
  Self.EstablishSession(Session);
  Check(Session.DialogEstablished,
        Session.ClassName + ': No dialog established');

  ReInvite := Self.CreateRemoteReInvite(Session.Dialog);
  try
    Check(Session.Match(ReInvite),
          Session.ClassName + ': In-dialog INVITE must match session');
  finally
    ReInvite.Free;
  end;
end;

procedure TestTIdSipSession.TestModifyBeforeFullyEstablished;
var
  Session: TIdSipSession;
begin
  Session := Self.CreateAction as TIdSipSession;

  try
    Session.Modify('', '');
    Fail('Failed to bail out starting a modify before session''s established');
  except
     on EIdSipTransactionUser do;
  end;
end;

procedure TestTIdSipSession.TestModifyDuringModification;
var
  Session: TIdSipSession;
begin
  Session := Self.CreateAndEstablishSession;
  Session.Modify('', '');

  try
    Session.Modify('', '');
    Fail('Failed to bail out starting a new modify while one''s in progress');
  except
    on EIdSipTransactionUser do;
  end;
end;

procedure TestTIdSipSession.TestModifyGlareInbound;
var
  Session: TIdSipSession;
begin
  // Essentially, we and Remote send INVITEs simultaneously.
  // We send ours, and it arrives after the remote end's sent us its INVITE.
  // When we receive its INVITE, we reject it with a 491 Request Pending.

  Session := Self.CreateAndEstablishSession;
  Session.Modify('', '');

  Self.MarkSentResponseCount;
  Self.ReceiveRemoteReInvite(Session);
  CheckResponseSent(Session.ClassName + ': No response sent');
  CheckEquals(SIPRequestPending,
              Dispatcher.Transport.LastResponse.StatusCode,
              Session.ClassName + ': Unexpected response');
end;

procedure TestTIdSipSession.TestModifyGlareOutbound;
const
  Body = 'random data';
var
  EventCount:  Integer;
  LatestEvent: TIdWait;
  Session:     TIdSipSession;
begin
  // Essentially, we and Remote send INVITEs simultaneously
  // We send ours and, because the remote end's sent its before ours arrives,
  // we receive its 491 Request Pending. We schedule a time to resend our
  // INVITE.

  Session := Self.CreateAndEstablishSession;

  Self.DebugTimer.TriggerAllEventsOfType(TIdSipActionsWait);
  Session.Modify(Body, PlainTextMimeType);

  EventCount := Self.DebugTimer.EventCount;
  Self.ReceiveResponse(SIPRequestPending);

  Self.DebugTimer.LockTimer;
  try
    Check(EventCount < Self.DebugTimer.EventCount,
          Session.ClassName + ': No timer added');

    LatestEvent := Self.DebugTimer.LastEventScheduled;

    Check(Assigned(LatestEvent),
          Session.ClassName + ': Wrong notify event');
    Self.CheckResendWaitTime(LatestEvent.DebugWaitTime,
                             Session.ClassName + ': Bad wait time (was '
                           + IntToStr(LatestEvent.DebugWaitTime) + ' milliseconds)');
  finally
    Self.DebugTimer.UnlockTimer;
  end;

  Self.MarkSentRequestCount;
  Self.DebugTimer.TriggerAllEventsOfType(TIdSipActionsWait);
  CheckRequestSent('No request sent: event not scheduled?');
  CheckEquals(MethodInvite,
              Self.LastSentRequest.Method,
              'Unexpected request');
  CheckEquals(Body,
              Self.LastSentRequest.Body,
              'Wrong message sent?');
end;

procedure TestTIdSipSession.TestModifyRejected;
var
  OldSessionDescription: String;
  OldSessionMimeType:    String;
  Session: TIdSipSession;
begin
  Session := Self.CreateAndEstablishSession;

  OldSessionDescription := Session.LocalSessionDescription;
  OldSessionMimeType    := Session.LocalMimeType;

  Session.Modify('new session desc', PlainTextMimeType);
  Self.ReceiveServiceUnavailable(Self.LastSentRequest);

  CheckEquals(OldSessionDescription,
              Session.LocalSessionDescription,
              'Session description altered');
  CheckEquals(OldSessionMimeType,
              Session.LocalMimeType,
              'Session MIME type altered');
end;

procedure TestTIdSipSession.TestModifyRejectedWithTimeout;
var
  ClassName:    String;
  Session:      TIdSipSession;
  SessionCount: Integer;
begin
  Session := Self.CreateAction as TIdSipSession;
  Self.EstablishSession(Session);
  ClassName := Session.ClassName;

  Session.Modify('', '');

  Self.MarkSentRequestCount;
  SessionCount := Self.Core.SessionCount;

  Self.ReceiveResponse(SIPRequestTimeout);

  CheckRequestSent(ClassName + ': No request sent');
  CheckEquals(MethodBye,
              Self.LastSentRequest.Method,
              ClassName + ': Unexpected request sent');
  Check(Self.Core.SessionCount < SessionCount,
        ClassName + ': Session not terminated');
end;

procedure TestTIdSipSession.TestModifyWaitTime;
var
  I:       Integer;
  Session: TIdSipSession;
begin
  Session := Self.CreateAction as TIdSipSession;

  // The modify wait time is random; this test does not guarantee that the wait
  // time is always correct!
  for I := 1 to 100 do
    CheckResendWaitTime(Session.ModifyWaitTime, Session.ClassName);
end;

procedure TestTIdSipSession.TestReceiveByeWithPendingRequests;
var
  Bye:      TIdSipRequest;
  ReInvite: TIdSipRequest;
  Session:  TIdSipSession;
begin
  // <---         INVITE          ---
  //  ---         200 OK          --->
  // <---          ACK            ---
  // <---         INVITE          ---
  // <---          BYE            ---
  //  ---  487 Request Terminated --- (for the re-INVITE)
  // <---          ACK            ---
  //  ---         200 OK          ---> (for the BYE)
  Session := Self.CreateAndEstablishSession;

  Self.ReceiveRemoteReInvite(Session);

  ReInvite := TIdSipRequest.Create;
  try
    ReInvite.Assign(Self.Invite);

    Self.MarkSentResponseCount;

    Bye := Self.CreateRemoteBye(Session.Dialog);
    try
      Self.ReceiveRequest(Bye);

      Check(Self.ResponseCount + 2 <= Self.SentResponseCount,
            Self.ClassName + ': No responses to both BYE and re-INVITE');

      Check(Bye.InSameDialogAs(Self.LastSentResponse),
            Self.ClassName + ': No response for BYE');
      CheckEquals(SIPOK,
                  Self.LastSentResponse.StatusCode,
                  Self.ClassName + ': Wrong response for BYE');

      Check(ReInvite.Match(Self.SecondLastSentResponse),
            Self.ClassName + ': No response for re-INVITE');
      CheckEquals(SIPRequestTerminated,
                  Self.SecondLastSentResponse.StatusCode,
                  Self.ClassName + ': Wrong response for re-INVITE');
    finally
      Bye.Free;
    end;
  finally
    ReInvite.Free;
  end;
end;

procedure TestTIdSipSession.TestModify;
var
  Session: TIdSipSession;
begin
  Session := Self.CreateAction as TIdSipSession;
  Self.EstablishSession(Session);

  Self.MarkSentRequestCount;
  Session.Modify(Self.SimpleSdp.AsString, SdpMimeType);
  CheckRequestSent(Session.ClassName + ': No INVITE sent');

  Self.ReceiveOkWithBody(Self.LastSentRequest,
                         Format(DummySDP, ['127.0.0.1']),
                         SdpMimeType);
  Check(Self.OnModifiedSessionFired,
        Session.ClassName + ': OnModifiedSession didn''t fire');

  CheckEquals(Self.SimpleSdp.AsString,
              Session.LocalSessionDescription,
              'Session.LocalSessionDescription');
  CheckEquals(SdpMimeType,
              Session.LocalMimeType,
              'Session.LocalMimeType');
  CheckEquals(Format(DummySDP, ['127.0.0.1']),
              Self.RemoteSessionDescription,
              'RemoteSessionDescription');
  CheckEquals(SdpMimeType,
              Self.MimeType,
              'MimeType');
  CheckEquals(Self.RemoteSessionDescription,
              Session.RemoteSessionDescription,
              'Session.RemoteSessionDescription');
  CheckEquals(Self.MimeType,
              Session.RemoteMimeType,
              'Session.RemoteMimeType');
end;

procedure TestTIdSipSession.TestRejectInviteWhenInboundModificationInProgress;
var
  FirstInvite: TIdSipRequest;
  Session:     TIdSipSession;
begin
  //           <established session>
  //  <---           INVITE 1           ---
  //  <---           INVITE 2           ---
  //   ---  491 Request Pending (for 2) --->
  //  <---         ACK (for 2)          ---
  //   ---        200 OK (for 1)        --->
  //  <---        ACK (for 1)           ---

  FirstInvite := TIdSipRequest.Create;
  try
    Session := Self.CreateAndEstablishSession;

    Self.ReceiveRemoteReInvite(Session);
    FirstInvite.Assign(Self.Dispatcher.Transport.LastRequest);
    Check(Self.OnModifySessionFired,
          Session.ClassName + ': OnModifySession didn''t fire');

    Self.MarkSentResponseCount;
    Self.OnModifySessionFired := false;
    Self.ReceiveRemoteReInvite(Session);
    Check(not Self.OnModifySessionFired,
          Session.ClassName + ': OnModifySession fired for a 2nd modify');
    CheckResponseSent(Session.ClassName + ': No 491 response sent');
    CheckEquals(SIPRequestPending,
                Self.LastSentResponse.StatusCode,
                Session.ClassName + ': Unexpected response to 2nd INVITE');
    Check(Self.Invite.Match(Self.LastSentResponse),
          Session.ClassName + ': Response doesn''t match 2nd INVITE');
    Self.ReceiveAck;
    Check(Session.ModificationInProgress,
          Session.ClassName + ': Modification should still be ongoing');

    Self.MarkSentResponseCount;
    Session.AcceptModify('', '');

    CheckResponseSent(Session.ClassName + ': No 200 response sent');
    CheckEquals(SIPOK,
                Self.LastSentResponse.StatusCode,
                Session.ClassName + ': Unexpected response to 1st INVITE');
    Check(FirstInvite.Match(Self.LastSentResponse),
          Session.ClassName + ': Response doesn''t match 1st INVITE');

    Self.ReceiveAckFor(FirstInvite,
                       Self.LastSentResponse);
    Check(not Session.ModificationInProgress,
          Session.ClassName + ': Modification should have finished');
  finally
    FirstInvite.Free;
  end;
end;

procedure TestTIdSipSession.TestRejectInviteWhenOutboundModificationInProgress;
var
  FirstInvite: TIdSipRequest;
  Session:     TIdSipSession;
begin
  //          <established session>
  //   ---           INVITE 1           --->
  //  <---           INVITE 2           ---
  //   ---  491 Request Pending (for 2) --->
  //  <---         ACK (for 2)          ---
  //  <---        200 OK (for 1)        ---
  //   ---        ACK (for 1)           --->

  FirstInvite := TIdSipRequest.Create;
  try
    Session := Self.CreateAndEstablishSession;
    Session.AddSessionListener(Self);

    Self.MarkSentRequestCount;
    Session.Modify('', '');
    CheckRequestSent('No modifying INVITE sent: ' + Self.FailReason);
    FirstInvite.Assign(Self.LastSentRequest);

    Self.MarkSentResponseCount;
    Self.ReceiveRemoteReInvite(Session);
    CheckResponseSent(Session.ClassName + ': No 491 response sent');
    CheckEquals(SIPRequestPending,
                Self.LastSentResponse.StatusCode,
                Session.ClassName + ': Unexpected response');
    Self.ReceiveAck;

    Self.MarkSentAckCount;
    Self.ReceiveOk(FirstInvite);
    CheckAckSent(Session.ClassName + ': No ACK sent');
  finally
    FirstInvite.Free;
  end;
end;

procedure TestTIdSipSession.TestRemodify;
const
  Body = 'random data';
var
  Session: TIdSipSession;
begin
  //      <establish session>
  //  ---       INVITE 1       --->
  // <---  491 Request Pending ---
  //  ---         ACK          --->
  //         <time passes>
  //  ---       INVITE 2       ---> (with same body as INVITE 1)

  Session := Self.CreateAndEstablishSession;
  Session.Modify(Body, PlainTextMimeType);
  Self.ReceiveResponse(Self.LastSentRequest, SIPRequestPending);

  Self.MarkSentRequestCount;
  Session.Remodify;
  CheckRequestSent('No request sent');
  CheckEquals(MethodInvite,
              Self.LastSentRequest.Method,
              'Unexpected request sent');
  CheckEquals(Body,
              Self.LastSentRequest.Body,
              'Unexpected body in request');
end;

//******************************************************************************
//* TestTIdSipInboundSession                                                   *
//******************************************************************************
//* TestTIdSipInboundSession Public methods ************************************

procedure TestTIdSipInboundSession.SetUp;
begin
  inherited SetUp;

  Self.Core.AddUserAgentListener(Self);

  Self.OnEndedSessionFired    := false;
  Self.OnModifiedSessionFired := false;
  Self.SentRequestTerminated  := false;

  Self.Invite.ContentType   := SdpMimeType;
  Self.Invite.Body          := Self.SimpleSdp.AsString;
  Self.Invite.ContentLength := Length(Self.SimpleSdp.AsString);

  Self.Locator.AddA(Self.Invite.RequestUri.Host, '127.0.0.1');
end;

procedure TestTIdSipInboundSession.TearDown;
begin
  Self.Core.TerminateAllCalls;

  inherited TearDown;
end;

//* TestTIdSipInboundSession Protected methods *********************************

procedure TestTIdSipInboundSession.CheckResendWaitTime(Milliseconds: Cardinal;
                                                       const Msg: String);
begin
  Check(Milliseconds <= 2000, Msg);

  inherited CheckResendWaitTime(Milliseconds, Msg);
end;

function TestTIdSipInboundSession.CreateAction: TIdSipAction;
begin
  Self.Invite.Body := Self.RemoteDesc;

  if (Self.Invite.Body <> '') then
    Self.Invite.ContentType := Self.RemoteContentType;

  Self.Invite.ContentLength := Length(Self.RemoteDesc);

  Self.Invite.LastHop.Branch := Self.Core.NextBranch;
  Self.Invite.From.Tag       := Self.Core.NextTag;
  Self.ReceiveInvite;

  Check(Assigned(Self.Session), 'OnInboundCall not called');

  Result := Self.Session;
end;

procedure TestTIdSipInboundSession.EstablishSession(Session: TIdSipSession);
begin
  (Session as TIdSipInboundSession).AcceptCall('', '');
  Self.ReceiveAck;
end;

//* TestTIdSipInboundSession Private methods ***********************************

procedure TestTIdSipInboundSession.OnAuthenticationChallenge(UserAgent: TIdSipAbstractUserAgent;
                                                             Challenge: TIdSipResponse;
                                                             var Username: String;
                                                             var Password: String;
                                                             var TryAgain: Boolean);
begin
end;

procedure TestTIdSipInboundSession.OnDroppedUnmatchedMessage(UserAgent: TIdSipAbstractUserAgent;
                                                             Message: TIdSipMessage;
                                                             Receiver: TIdSipTransport);
begin
end;

procedure TestTIdSipInboundSession.OnEndedSession(Session: TIdSipSession;
                                                  ErrorCode: Cardinal;
                                                  const Reason: String);
begin
  inherited OnEndedSession(Session, ErrorCode, Reason);
  Self.ActionFailed := true;

  Self.ThreadEvent.SetEvent;
end;

procedure TestTIdSipInboundSession.OnEstablishedSession(Session: TIdSipSession;
                                                        const RemoteSessionDescription: String;
                                                        const MimeType: String);
begin
end;

procedure TestTIdSipInboundSession.OnInboundCall(UserAgent: TIdSipUserAgent;
                                                 Session: TIdSipInboundSession);
begin
  Self.Session := Session;
  Self.Session.AddSessionListener(Self);
end;

procedure TestTIdSipInboundSession.OnNewData(Data: TIdRTPPayload;
                                             Binding: TIdConnection);
begin
  Self.ThreadEvent.SetEvent;
end;

procedure TestTIdSipInboundSession.OnSendRequest(Request: TIdSipRequest;
                                                 Sender: TIdSipTransport);
begin
end;

procedure TestTIdSipInboundSession.OnSendResponse(Response: TIdSipResponse;
                                                  Sender: TIdSipTransport);
begin
  if (Response.StatusCode = SIPRequestTerminated) then
    Self.SentRequestTerminated := true;
end;

procedure TestTIdSipInboundSession.ReceiveAckWithBody(const SessionDesc,
                                                      ContentType: String);
var
  Ack: TIdSipRequest;
begin
  Ack := Self.Invite.AckFor(Self.LastSentResponse);
  try
    Ack.Body          := SessionDesc;
    Ack.ContentType   := ContentType;
    Ack.ContentLength := Length(Ack.Body);

    Self.ReceiveRequest(Ack);
  finally
    Ack.Free;
  end;
end;

//* TestTIdSipInboundSession Published methods ****************************************

procedure TestTIdSipInboundSession.TestAcceptCall;
var
  Answer:         String;
  AnswerMimeType: String;
begin
  Self.RemoteContentType := SdpMimeType;
  Self.RemoteDesc        := TIdSipTestResources.BasicSDP('proxy.tessier-ashpool.co.luna');
  Self.CreateAction;
  CheckEquals(Self.RemoteDesc,
              Self.Session.RemoteSessionDescription,
              'RemoteSessionDescription');
  CheckEquals(Self.RemoteContentType,
              Self.Session.RemoteMimeType,
              'RemoteMimeType');

  Answer         := TIdSipTestResources.BasicSDP('public.booth.org');
  AnswerMimeType := SdpMimeType;

  Self.Session.AcceptCall(Answer, AnswerMimeType);

  Check(Self.Session.DialogEstablished,
        'Dialog not established');
  CheckNotNull(Self.Session.Dialog,
               'Dialog object wasn''t created');
  CheckEquals(Answer,         Self.Session.LocalSessionDescription, 'LocalSessionDescription');
  CheckEquals(AnswerMimeType, Self.Session.LocalMimeType,           'LocalMimeType');
end;

procedure TestTIdSipInboundSession.TestAddSessionListener;
var
  L1, L2: TIdSipTestSessionListener;
begin
  Self.CreateAction;
  Self.Session.AcceptCall('', '');
  Self.ReceiveAck;

  L1 := TIdSipTestSessionListener.Create;
  try
    L2 := TIdSipTestSessionListener.Create;
    try
      Self.Session.AddSessionListener(L1);
      Self.Session.AddSessionListener(L2);

      Self.Session.Terminate;

      Check(L1.EndedSession, 'First listener not notified');
      Check(L2.EndedSession, 'Second listener not notified');

      Self.Session.RemoveSessionListener(L1);
      Self.Session.RemoveSessionListener(L2);
    finally
      L2.Free;
    end;
  finally
    L1.Free;
  end;
end;

procedure TestTIdSipInboundSession.TestCancelAfterAccept;
var
  CancelResponse: TIdSipResponse;
  InviteResponse: TIdSipResponse;
  SessionCount:   Integer;
begin
  // <--- INVITE ---
  //  --- 200 OK --->
  // <---  ACK   ---
  // <--- CANCEL ---
  //  --- 200 OK --->
  Self.CreateAction;
  Self.Session.AcceptCall('', '');

  Self.MarkSentResponseCount;
  SessionCount  := Self.Core.SessionCount;
  Self.ReceiveCancel;

  CheckEquals(SessionCount,
              Self.Core.SessionCount,
              'Session terminated and the UA cleaned it up');
  Check(not Self.Session.IsTerminated,
        'Session terminated');
  CheckResponseSent('No response sent');

  CancelResponse := Self.LastSentResponse;
  InviteResponse := Self.Dispatcher.Transport.SecondLastResponse;

  CheckEquals(SIPOK,
              CancelResponse.StatusCode,
              'Unexpected Status-Code for CANCEL response');
  CheckEquals(MethodCancel,
              CancelResponse.CSeq.Method,
              'Unexpected CSeq method for CANCEL response');

  CheckEquals(SIPOK,
              InviteResponse.StatusCode,
              'Unexpected Status-Code for INVITE response');
  CheckEquals(MethodInvite,
              InviteResponse.CSeq.Method,
              'Unexpected CSeq method for INVITE response');
end;

procedure TestTIdSipInboundSession.TestCancelBeforeAccept;
var
  SessionCount: Integer;
begin
  // <---         INVITE         ---
  // <---         CANCEL         ---
  //  ---         200 OK         ---> (for the CANCEL)
  //  --- 487 Request Terminated ---> (for the INVITE)
  // <---           ACK          ---
  Self.CreateAction;
  SessionCount := Self.Core.SessionCount;

  Self.ReceiveCancel;

  // The UA clears out terminated sessions as soon as it finishes handling
  // a message, so the session should have terminated.
  Check(Self.Core.SessionCount < SessionCount,
        'Session didn''t terminate');

  Check(Self.OnEndedSessionFired,
        'Session didn''t notify listeners of ended session');
  CHeckEquals(NoError,
              Self.ErrorCode,
              'A remote cancel''s not an erroneous condition. ErrorCode set.');
  CheckEquals('',
              Self.Reason,
              'Reason param set');
end;

procedure TestTIdSipInboundSession.TestReceiveOutOfOrderReInvite;
var
  Response: TIdSipResponse;
begin
  // <--- INVITE (Branch = z9hG4bK776asdhds)  ---
  //  ---         100 Trying                  --->
  //  ---         180 Ringing                 --->
  //  ---         200 OK                      --->
  // <--- INVITE (Branch = z9hG4bK776asdhds1) ---
  //  ---         100 Trying                  --->
  //  ---         180 Ringing                 --->
  //  ---         500 Internal Server Error   --->

  Self.CreateAction;
  Check(Assigned(Self.Session), 'OnInboundCall not called');

  Self.Session.AcceptCall('', '');

  Self.Invite.LastHop.Branch := Self.Invite.LastHop.Branch + '1';
  Self.Invite.CSeq.SequenceNo := Self.Invite.CSeq.SequenceNo - 1;
  Self.Invite.ToHeader.Tag := Self.LastSentResponse.ToHeader.Tag;

  Self.MarkSentResponseCount;
  Self.ReceiveInvite;
  CheckResponseSent('No response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPInternalServerError,
              Response.StatusCode,
              'Unexpected response (' + Response.StatusText + ')');
  CheckEquals(RSSIPRequestOutOfOrder,
              Response.StatusText,
              'Unexpected response, status text');
end;

procedure TestTIdSipInboundSession.TestCancelNotifiesSession;
var
  SessionCount: Integer;
begin
  Self.CreateAction;
  SessionCount := Self.Core.SessionCount;

  Self.ReceiveCancel;

  Check(Self.OnEndedSessionFired,
        'No notification of ended session');

  Check(Self.Core.SessionCount < SessionCount,
        'Session not marked as terminated');
end;

procedure TestTIdSipInboundSession.TestInviteHasNoOffer;
var
  Answer:     String;
  AnswerType: String;
  Offer:      String;
  OfferType:  String;
begin
  // <--- INVITE (with no body) ---
  //  ---  200 OK (with offer)  ---
  // <---   ACK (with answer)   ---
  Self.RemoteContentType := '';
  Self.RemoteDesc        := '';
  Self.CreateAction;

  Check(Assigned(Self.Session), 'OnInboundCall not called');

  Offer := TIdSipTestResources.BasicSDP('localhost');
  OfferType := SdpMimeType;

  Self.MarkSentResponseCount;
  Self.Session.AcceptCall(Offer, OfferType);

  CheckResponseSent('No 200 OK sent');
  CheckEquals(Offer,
              Self.LastSentResponse.Body,
              'Offer');
  CheckEquals(OfferType,
              Self.LastSentResponse.ContentType,
              'Offer MIME type');

  Answer     := TIdSipTestResources.BasicSDP('remotehost');
  AnswerType := SdpMimeType;

  Self.ReceiveAckWithBody(Answer, AnswerType);
  CheckEquals(Self.Session.RemoteSessionDescription,
              Answer,
              'RemoteSessionDescription');
  CheckEquals(Self.Session.RemoteMimeType,
              AnswerType,
              'RemoteMimeType');
end;

procedure TestTIdSipInboundSession.TestInviteHasOffer;
var
  Answer:     String;
  AnswerType: String;
begin
  // <---    INVITE (with offer)     ---
  //  ---    200 OK (with answer)    ---
  // <--- ACK (with repeat of offer) ---
  Self.RemoteContentType := SdpMimeType;
  Self.RemoteDesc        := TIdSipTestResources.BasicSDP('1.2.3.4');
  Self.CreateAction;

  Check(Assigned(Self.Session), 'OnInboundCall not called');

  Answer := TIdSipTestResources.BasicSDP('localhost');
  AnswerType := SdpMimeType;

  Self.MarkSentResponseCount;
  Self.Session.AcceptCall(Answer, AnswerType);

  CheckResponseSent('No 200 OK sent');
  CheckEquals(Answer,
              Self.LastSentResponse.Body,
              'Answer');
  CheckEquals(AnswerType,
              Self.LastSentResponse.ContentType,
              'Answer MIME type');
end;

procedure TestTIdSipInboundSession.TestIsInbound;
begin
  Self.CreateAction;
  Check(Self.Session.IsInbound,
        Self.Session.ClassName + ' not marked as inbound');
end;

procedure TestTIdSipInboundSession.TestIsOutboundCall;
begin
  Self.CreateAction;
  Check(not Self.Session.IsOutboundCall,
        'Inbound session; IsOutboundCall');
end;

procedure TestTIdSipInboundSession.TestMethod;
begin
  CheckEquals(MethodInvite,
              TIdSipInboundSession.Method,
              'Inbound session; Method');
end;

procedure TestTIdSipInboundSession.TestNotifyListenersOfEstablishedSession;
var
  Answer:         String;
  AnswerMimeType: String;
  Listener:       TIdSipTestSessionListener;
begin
  Answer         := TIdSipTestResources.BasicSDP('public.booth.org');
  AnswerMimeType := SdpMimeType;
  Self.RemoteContentType := SdpMimeType;
  Self.RemoteDesc        := TIdSipTestResources.BasicSDP('proxy.tessier-ashpool.co.luna');
  Self.CreateAction;

  Listener := TIdSipTestSessionListener.Create;
  try
    Self.Session.AddSessionListener(Listener);
    Self.Session.AcceptCall(Answer, AnswerMimeType);

    Self.ReceiveAckWithBody(Self.RemoteDesc, Self.RemoteContentType);

    Check(Listener.EstablishedSession, 'No EstablishedSession notification');
  finally
    Self.Session.RemoveSessionListener(Listener);
    Listener.Free;
  end;
end;

procedure TestTIdSipInboundSession.TestNotifyListenersOfEstablishedSessionInviteHasNoBody;
var
  Answer:         String;
  AnswerMimeType: String;
  Listener:       TIdSipTestSessionListener;
begin
  Answer         := TIdSipTestResources.BasicSDP('public.booth.org');
  AnswerMimeType := SdpMimeType;
  Self.RemoteContentType := '';
  Self.RemoteDesc        := '';
  Self.CreateAction;

  Listener := TIdSipTestSessionListener.Create;
  try
    Self.Session.AddSessionListener(Listener);
    Self.Session.AcceptCall(Answer, AnswerMimeType);

    Self.ReceiveAckWithBody(Self.RemoteDesc, Self.RemoteContentType);

    Check(Listener.EstablishedSession, 'No EstablishedSession notification');
  finally
    Self.Session.RemoveSessionListener(Listener);
    Listener.Free;
  end;
end;

procedure TestTIdSipInboundSession.TestInboundModifyBeforeFullyEstablished;
var
  InternalServerError: TIdSipResponse;
  Invite:              TIdSipRequest;
  Ringing:             TIdSipResponse;
begin
  //  <---           INVITE          --- (with CSeq: n INVITE)
  //   ---         100 Trying        --->
  //   ---         180 Ringing       --->
  //  <---           INVITE          --- (with CSeq: n+1 INVITE)
  //   --- 500 Internal Server Error ---> (with Retry-After)
  //  <---            ACK            ---
  //   --->         200 OK           --->
  //  <---            ACK            ---

  // We need the Ringing response to get the To tag - Ringing establishes the
  // dialog!
  Self.CreateAction;

  Ringing := Self.LastSentResponse;
  CheckEquals(SIPRinging,
              Ringing.StatusCode,
              'Sanity check');
  Check(Assigned(Self.Session), 'OnInboundCall not called');
  Check(Self.Session.DialogEstablished,
        'Session should have established a dialog - it''s sent a 180, after all');

  Self.MarkSentResponseCount;
  Invite := TIdSipRequest.Create;
  try
    Invite.Assign(Self.Session.InitialRequest);
    Invite.LastHop.Branch  := Self.Core.NextBranch;
    Invite.CSeq.SequenceNo := Self.Session.InitialRequest.CSeq.SequenceNo + 1;
    Invite.ToHeader.Tag    := Ringing.ToHeader.Tag;
    Self.ReceiveRequest(Invite);
  finally
    Invite.Free;
  end;

  CheckResponseSent('No response sent');

  InternalServerError := Self.LastSentResponse;
  CheckEquals(SIPInternalServerError,
              InternalServerError.StatusCode,
              'Unexpected response');
  Check(InternalServerError.HasHeader(RetryAfterHeader),
        'No Retry-After header');
  Check(InternalServerError.FirstRetryAfter.NumericValue <= MaxPrematureInviteRetry,
        'Bad Retry-After value (' + IntToStr(InternalServerError.FirstRetryAfter.NumericValue) + ')');

  Self.ReceiveAck;
end;

procedure TestTIdSipInboundSession.TestInboundModifyReceivesNoAck;
begin
  // <---    INVITE   ---
  //  --- 180 Ringing --->
  // <---     ACK     ---
  // <---    INVITE   ---
  //  ---    200 OK   --->
  //   <no ACK returned>
  //  ---     BYE     --->
  Self.CreateAction;

  Check(Assigned(Self.Session), 'OnInboundCall not called');
  Self.Session.AcceptCall('', '');
  Self.ReceiveAck;

  Self.ReceiveRemoteReInvite(Self.Session);
  Check(Self.OnModifySessionFired,
        'OnModifySession didn''t fire');
  Self.Session.AcceptModify('', '');

  Self.MarkSentRequestCount;

  // This will fire all Resend OK attempts (and possibly some other events),
  // making the inbound INVITE fail.
  Self.DebugTimer.TriggerAllEventsOfType(TIdSipActionsWait);

  CheckRequestSent('No BYE sent to terminate the dialog');

  CheckEquals(MethodBye,
              Self.LastSentRequest.Method,
              'Unexpected request sent');
end;

procedure TestTIdSipInboundSession.TestReceiveBye;
begin
  Self.CreateAction;
  Check(Assigned(Self.Session), 'OnInboundCall not called');
  Self.Session.AcceptCall('', '');

  Self.ReceiveBye(Self.Session.Dialog);

  Check(Self.OnEndedSessionFired, 'OnEndedSession didn''t fire');
end;

procedure TestTIdSipInboundSession.TestRedirectCall;
var
  Dest:         TIdSipAddressHeader;
  SentResponse: TIdSipResponse;
begin
  Self.CreateAction;
  Check(Assigned(Self.Session), 'OnInboundCall not called');
  Self.MarkSentResponseCount;

  Dest := TIdSipAddressHeader.Create;
  try
    Dest.DisplayName := 'Wintermute';
    Dest.Address.Uri := 'sip:wintermute@talking-head.tessier-ashpool.co.luna';

    Self.Session.RedirectCall(Dest);
    CheckResponseSent('No response sent');

    SentResponse := Self.LastSentResponse;
    CheckEquals(SIPMovedTemporarily,
                SentResponse.StatusCode,
                'Wrong response sent');
    Check(SentResponse.HasHeader(ContactHeaderFull),
          'No Contact header');
    CheckEquals(Dest.DisplayName,
                SentResponse.FirstContact.DisplayName,
                'Contact display name');
    CheckEquals(Dest.Address.Uri,
                SentResponse.FirstContact.Address.Uri,
                'Contact address');

    Check(Self.OnEndedSessionFired, 'OnEndedSession didn''t fire');
  finally
    Dest.Free;
  end;
end;

procedure TestTIdSipInboundSession.TestRejectCallBusy;
begin
  Self.CreateAction;
  Check(Assigned(Self.Session), 'OnInboundCall not called');

  Self.MarkSentResponseCount;
  Self.Session.RejectCallBusy;
  CheckResponseSent('No response sent');
  CheckEquals(SIPBusyHere,
              Self.LastSentResponse.StatusCode,
              'Wrong response sent');

  Check(Self.OnEndedSessionFired, 'OnEndedSession didn''t fire');
end;

procedure TestTIdSipInboundSession.TestRemoveSessionListener;
var
  L1, L2: TIdSipTestSessionListener;
begin
  Self.CreateAction;
  Check(Assigned(Self.Session), 'OnInboundCall not called');

  Self.Session.AcceptCall('', '');

  L1 := TIdSipTestSessionListener.Create;
  try
    L2 := TIdSipTestSessionListener.Create;
    try
      Self.Session.AddSessionListener(L1);
      Self.Session.AddSessionListener(L2);
      Self.Session.RemoveSessionListener(L2);

      Self.Session.Terminate;

      Check(L1.EndedSession,
            'First listener not notified');
      Check(not L2.EndedSession,
            'Second listener erroneously notified, ergo not removed');
    finally
      L2.Free
    end;
  finally
    L1.Free;
  end;
end;

procedure TestTIdSipInboundSession.TestTerminate;
var
  Request:      TIdSipRequest;
  SessionCount: Integer;
begin
  Self.CreateAction;
  Check(Assigned(Self.Session), 'OnInboundCall not called');

  Self.MarkSentRequestCount;
  Self.Session.AcceptCall('', '');

  SessionCount := Self.Core.SessionCount;
  Self.Session.Terminate;

  CheckRequestSent('no BYE sent');

  Request := Self.LastSentRequest;
  Check(Request.IsBye, 'Unexpected last request');

  Check(Self.Core.SessionCount < SessionCount,
        'Session not marked as terminated');
end;

procedure TestTIdSipInboundSession.TestTerminateUnestablishedSession;
var
  Response:     TIdSipResponse;
  SessionCount: Integer;
begin
  Self.CreateAction;
  Check(Assigned(Self.Session), 'OnInboundCall not called');

  Self.MarkSentResponseCount;
  SessionCount  := Self.Core.SessionCount;

  Self.Session.Terminate;

  CheckResponseSent('no response sent');

  Response := Self.LastSentResponse;
  CheckEquals(SIPRequestTerminated,
              Response.StatusCode,
              'Unexpected last response');

  Check(Self.Core.SessionCount < SessionCount,
        'Session not marked as terminated');
end;

//******************************************************************************
//* TestTIdSipOutboundSession                                                  *
//******************************************************************************
//* TestTIdSipOutboundSession Public methods ***********************************

procedure TestTIdSipOutboundSession.SetUp;
begin
  inherited SetUp;

  Self.Dispatcher.Transport.WriteLog := true;

  Self.MimeType := SdpMimeType;
  Self.SDP :='v=0'#13#10
           + 'o=franks 123456 123456 IN IP4 127.0.0.1'#13#10
           + 's=-'#13#10
           + 'c=IN IP4 127.0.0.1'#13#10
           + 'm=audio 8000 RTP/AVP 0'#13#10;

  Self.Core.AddUserAgentListener(Self);

  Self.Session := Self.CreateAction as TIdSipOutboundSession;

  Self.RemoteMimeType           := '';
  Self.OnDroppedMessage         := false;
  Self.OnEndedSessionFired      := false;
  Self.OnModifiedSessionFired   := false;
  Self.OnProgressedSessionFired := false;
  Self.RemoteDesc               := '';

  // DNS entries for redirected domains, etc.
  Self.Locator.AddA('bar.org',   '127.0.0.1');
  Self.Locator.AddA('quaax.org', '127.0.0.1');
end;

//* TestTIdSipOutboundSession Protectedivate methods ***************************

procedure TestTIdSipOutboundSession.CheckResendWaitTime(Milliseconds: Cardinal;
                                                       const Msg: String);
begin
  Check((2100 <= Milliseconds) and (Milliseconds <= 4000), Msg);

  inherited CheckResendWaitTime(Milliseconds, Msg);
end;

function TestTIdSipOutboundSession.CreateAction: TIdSipAction;
var
  Session: TIdSipOutboundSession;
begin
  Session := Self.Core.InviteModule.Call(Self.Destination, Self.SDP, Self.MimeType);
  Session.AddSessionListener(Self);
  Session.Send;

  Result := Session;
end;

procedure TestTIdSipOutboundSession.EstablishSession(Session: TIdSipSession);
begin
  Self.ReceiveOk(Self.LastSentRequest);
end;

procedure TestTIdSipOutboundSession.OnEstablishedSession(Session: TIdSipSession;
                                                         const RemoteSessionDescription: String;
                                                         const MimeType: String);
begin
  inherited OnEstablishedSession(Session, RemoteSessionDescription, MimeType);

  Self.RemoteDesc     := RemoteSessionDescription;
  Self.RemoteMimeType := MimeType;

  Session.LocalSessionDescription := Self.LocalDescription;
  Session.LocalMimeType           := Self.LocalMimeType;
end;

procedure TestTIdSipOutboundSession.OnProgressedSession(Session: TIdSipSession;
                                                        Progress: TIdSipResponse);
begin
  inherited OnProgressedSession(Session, Progress);

  Self.OnProgressedSessionFired := true;
end;

//* TestTIdSipOutboundSession Private methods **********************************

procedure TestTIdSipOutboundSession.OnAuthenticationChallenge(UserAgent: TIdSipAbstractUserAgent;
                                                              Challenge: TIdSipResponse;
                                                              var Username: String;
                                                              var Password: String;
                                                              var TryAgain: Boolean);
begin
end;

procedure TestTIdSipOutboundSession.OnDroppedUnmatchedMessage(UserAgent: TIdSipAbstractUserAgent;
                                                              Message: TIdSipMessage;
                                                              Receiver: TIdSipTransport);
begin
  Self.OnDroppedMessage := true;
end;

procedure TestTIdSipOutboundSession.OnInboundCall(UserAgent: TIdSipUserAgent;
                                                  Session: TIdSipInboundSession);
begin
end;

procedure TestTIdSipOutboundSession.ReceiveBusyHere(Invite: TIdSipRequest);
var
  BusyHere: TIdSipResponse;
begin
  BusyHere := TIdSipResponse.InResponseTo(Invite,
                                          SIPBusyHere);
  try
    Self.ReceiveResponse(BusyHere);
  finally
    BusyHere.Free;
  end;
end;

procedure TestTIdSipOutboundSession.ReceiveForbidden;
var
  Response: TIdSipResponse;
begin
  Response := Self.Core.CreateResponse(Self.LastSentRequest,
                                       SIPForbidden);
  try
    Self.ReceiveResponse(Response);
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipOutboundSession.ReceiveMovedTemporarily(Invite: TIdSipRequest;
                                                            const Contacts: array of String);
var
  I:        Integer;
  Response: TIdSipResponse;
begin
  Response := TIdSipResponse.InResponseTo(Invite,
                                          SIPMovedTemporarily);
  try
    for I := Low(Contacts) to High(Contacts) do
      Response.AddHeader(ContactHeaderFull).Value := Contacts[I];

    Self.ReceiveResponse(Response);
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipOutboundSession.ReceiveMovedTemporarily(const Contact: String);
begin
  Self.ReceiveMovedTemporarily(Self.LastSentRequest, [Contact]);
end;

procedure TestTIdSipOutboundSession.ReceiveMovedTemporarily(const Contacts: array of String);
begin
  Self.ReceiveMovedTemporarily(Self.LastSentRequest, Contacts);
end;

procedure TestTIdSipOutboundSession.ReceiveOKWithRecordRoute;
var
  Response: TIdSipResponse;
begin
  Response := TIdSipResponse.InResponseTo(Self.LastSentRequest,
                                          SIPOK);
  try
    Response.RecordRoute.Add(RecordRouteHeader).Value := '<sip:127.0.0.1>';
    Self.ReceiveResponse(Response);
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipOutboundSession.ReceiveRemoteDecline;
var
  Decline: TIdSipResponse;
begin
  Decline := TIdSipResponse.InResponseTo(Self.LastSentRequest,
                                         SIPDecline);
  try
    Self.ReceiveResponse(Decline);
  finally
    Decline.Free;
  end;
end;

//* TestTIdSipOutboundSession Published methods ********************************

procedure TestTIdSipOutboundSession.TestAck;
var
  Ack:    TIdSipRequest;
  Invite: TIdSipRequest;
begin
  Invite := TIdSipRequest.Create;
  try
    Invite.Assign(Self.LastSentRequest);

    Self.ReceiveOk(Self.LastSentRequest);

    Ack := Self.Dispatcher.Transport.LastACK;

    CheckEquals(Self.Session.Dialog.RemoteTarget,
                Ack.RequestUri,
                'Request-URI');
    CheckEquals(Invite.CSeq.SequenceNo,
                Ack.CSeq.SequenceNo,
                'CSeq sequence number');

    CheckEquals(Invite.Body,
                Ack.Body,
                'Offer');
    CheckEquals(Length(Ack.Body),
                Ack.ContentLength,
                'Content-Length');
    CheckEquals(Invite.ContentType,
                Ack.ContentType,
                'Content-Type');
    CheckEquals(Invite.ContentDisposition.Value,
                Ack.ContentDisposition.Value,
                'Content-Disposition');
    Check(Ack.ContentDisposition.IsSession,
          'Content-Disposition handling');
    CheckNotEquals(Invite.LastHop.Branch,
                   Ack.LastHop.Branch,
                   'Branch must differ - a UAS creates an ACK as an '
                 + 'in-dialog request');
  finally
    Invite.Destroy;
  end;
end;

procedure TestTIdSipOutboundSession.TestAckFromRecordRouteResponse;
var
  Ack: TIdSipRequest;
begin
  Self.ReceiveOKWithRecordRoute;
  Ack := Self.Dispatcher.Transport.LastACK;

  Check(not Ack.Route.IsEmpty, 'No Route headers');
end;

procedure TestTIdSipOutboundSession.TestAckWithAuthorization;
var
  Ack:    TIdSipRequest;
  Invite: TIdSipRequest;
begin
  Self.ReceiveUnauthorized(WWWAuthenticateHeader, '');

  Invite := TIdSipRequest.Create;
  try
    Invite.Assign(Self.LastSentRequest);

    Self.ReceiveOk(Self.LastSentRequest);

    Ack := Self.LastSentRequest;

    Check(Ack.HasAuthorization, 'ACK lacks Authorization header');
    CheckEquals(Invite.FirstAuthorization.FullValue,
                Ack.FirstAuthorization.FullValue,
                'Authorization');
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestAckWithProxyAuthorization;
var
  Ack:    TIdSipRequest;
  Invite: TIdSipRequest;
begin
  Self.ReceiveUnauthorized(ProxyAuthenticateHeader, '');

  Invite := TIdSipRequest.Create;
  try
    Invite.Assign(Self.LastSentRequest);

    Self.ReceiveOk(Self.LastSentRequest);

    Ack := Self.LastSentRequest;

    Check(Ack.HasProxyAuthorization, 'ACK lacks Proxy-Authorization header');
    CheckEquals(Invite.FirstProxyAuthorization.FullValue,
                Ack.FirstProxyAuthorization.FullValue,
                'Proxy-Authorization');
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestCall;
var
  Invite:     TIdSipRequest;
  SessCount:  Integer;
  Session:    TIdSipSession;
  TranCount:  Integer;
  Answer:     String;
  AnswerType: String;
begin
  Self.MarkSentRequestCount;
  SessCount    := Self.Core.SessionCount;
  TranCount    := Self.Dispatcher.TransactionCount;

  Self.SDP      := TIdSipTestResources.BasicSDP('proxy.tessier-ashpool.co.luna');
  Self.MimeType := SdpMimeType;

  Session := Self.CreateAction as TIdSipSession;

  CheckEquals(Self.SDP,
              Session.LocalSessionDescription,
              'LocalSessionDescription');
  CheckEquals(Self.MimeType,
              Session.LocalMimeType,
              'LocalMimeType');

  CheckRequestSent('no INVITE sent');
  Invite := Self.LastSentRequest;

  CheckEquals(TranCount + 1,
              Self.Dispatcher.TransactionCount,
              'no client INVITE transaction created');

  CheckEquals(SessCount + 1,
              Self.Core.SessionCount,
              'no new session created');

  Self.ReceiveRinging(Invite);

  Check(Session.IsEarly,
        'Dialog in incorrect state: should be Early');
  Check(Session.DialogEstablished,
        'Dialog not established');
  Check(not Session.Dialog.IsSecure,
        'Dialog secure when TLS not used');

  CheckEquals(Self.Dispatcher.Transport.LastResponse.CallID,
              Session.Dialog.ID.CallID,
              'Dialog''s Call-ID');
  CheckEquals(Self.Dispatcher.Transport.LastResponse.From.Tag,
              Session.Dialog.ID.LocalTag,
              'Dialog''s Local Tag');
  CheckEquals(Self.Dispatcher.Transport.LastResponse.ToHeader.Tag,
              Session.Dialog.ID.RemoteTag,
              'Dialog''s Remote Tag');

  Answer     := TIdSipTestResources.BasicSDP('sip.fried-neurons.org');
  AnswerType := SdpMimeType;
  Self.ReceiveOkWithBody(Invite, Answer, AnswerType);

  CheckEquals(Answer,
              Session.RemoteSessionDescription,
              'RemoteSessionDescription');
  CheckEquals(AnswerType,
              Session.RemoteMimeType,
              'RemoteMimeType');

  Check(not Session.IsEarly, 'Dialog in incorrect state: shouldn''t be early');
end;

procedure TestTIdSipOutboundSession.TestCallNetworkFailure;
var
  SessionCount: Cardinal;
begin
  SessionCount := Self.Core.SessionCount;
  Self.Dispatcher.Transport.FailWith := EIdConnectTimeout;

  Self.CreateAction;

  CheckEquals(SessionCount,
              Self.Core.SessionCount,
              'Core should have axed the failed session');
end;

procedure TestTIdSipOutboundSession.TestCallRemoteRefusal;
begin
  Self.ReceiveForbidden;

  Check(Self.OnEndedSessionFired, 'OnEndedSession wasn''t triggered');
end;

procedure TestTIdSipOutboundSession.TestCallSecure;
var
  Response: TIdSipResponse;
  Session:  TIdSipSession;
begin
  Self.Dispatcher.TransportType := TlsTransport;

  Self.Destination.Address.Scheme := SipsScheme;
  Session := Self.CreateAction as TIdSipSession;

  Response := Self.Core.CreateResponse(Self.LastSentRequest,
                                       SIPRinging);
  try
    Self.ReceiveResponse(Response);

    Response.StatusCode := SIPOK;
    Check(Session.Dialog.IsSecure, 'Dialog not secure when TLS used');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestCallSipsUriOverTcp;
var
  SentInvite: TIdSipRequest;
  Session:    TIdSipSession;
begin
  Self.Dispatcher.TransportType := TcpTransport;
  Self.Destination.Address.Scheme := SipsScheme;

  Self.MarkSentRequestCount;

  Session := Self.CreateAction as TIdSipSession;

  CheckRequestSent('INVITE wasn''t sent');
  SentInvite := Self.LastSentRequest;

  Self.ReceiveRinging(SentInvite);

  Check(not Session.Dialog.IsSecure, 'Dialog secure when TCP used');
end;

procedure TestTIdSipOutboundSession.TestCallSipUriOverTls;
var
  Response: TIdSipResponse;
  Session:  TIdSipSession;
begin
  Self.Dispatcher.TransportType := TcpTransport;

  Session := Self.CreateAction as TIdSipSession;

  Response := Self.Core.CreateResponse(Self.LastSentRequest,
                                       SIPOK);
  try
    Response.FirstContact.Address.Scheme := SipsScheme;
    Self.MarkSentAckCount;
    Self.ReceiveResponse(Response);
    CheckAckSent('No ACK sent: ' + Self.FailReason);

    Check(not Session.Dialog.IsSecure, 'Dialog secure when TLS used with a SIP URI');
  finally
    Response.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestCallWithOffer;
var
  Answer:      String;
  ContentType: String;
begin
  //  ---     INVITE (with offer)     --->
  // <---       200 (with answer)     ---
  //  ---  ACK (with repeat of offer) --->

  Answer      := TIdSipTestResources.BasicSDP('1.1.1.1');
  ContentType := SdpMimeType;

  Check(Self.LastSentRequest.ContentDisposition.IsSession,
        'Content-Disposition');
  CheckEquals(Self.SDP,
              Self.LastSentRequest.Body,
              'INVITE offer');
  CheckEquals(SdpMimeType,
              Self.LastSentRequest.ContentType,
              'INVITE offer mime type');

  Self.MarkSentAckCount;

  Self.ReceiveOkWithBody(Self.LastSentRequest,
                         Answer,
                         ContentType);

  Check(Self.OnEstablishedSessionFired,
        'OnEstablishedSession didn''t fire');

  CheckEquals(Answer,
              Self.RemoteDesc,
              'Remote session description');
  CheckEquals(ContentType,
              Self.RemoteMimeType,
              'Remote description''s MIME type');

  CheckAckSent('No ACK sent');
  CheckEquals(Self.LastSentRequest.Body,
              Self.LastSentAck.Body,
              'ACK offer');
  CheckEquals(Self.LastSentRequest.ContentType,
              Self.LastSentAck.ContentType,
              'ACK offer MIME type');
end;

procedure TestTIdSipOutboundSession.TestCallWithoutOffer;
var
  OfferType: String;
  Offer:     String;
  Session:   TIdSipOutboundSession;
begin
  //  ---       INVITE      --->
  // <--- 200 (with offer)  ---
  //  --- ACK (with answer) --->

  OfferType := SdpMimeType;
  Offer     := TIdSipTestResources.BasicSDP('1.1.1.1');

  Self.MimeType := '';
  Self.SDP      := '';

  Session := Self.CreateAction as TIdSipOutboundSession;

  CheckEquals(Self.SDP,
              Self.LastSentRequest.Body,
              'INVITE body');
  CheckEquals(Self.MimeType,
              Self.LastSentRequest.ContentType,
              'INVITE Content-Type');

  Self.LocalDescription := TIdSipTestResources.BasicSDP('localhost');
  Self.LocalMimeType    := SdpMimeType;

  Self.MarkSentAckCount;
  Self.ReceiveOkWithBody(Self.LastSentRequest,
                         Offer,
                         OfferType);

  Check(Self.OnEstablishedSessionFired,
        'OnEstablishedSession didn''t fire');
  CheckEquals(Offer,
              Self.RemoteDesc,
              'Remote description');
  CheckEquals(OfferType,
              Self.RemoteMimeType,
              'Remote description''s MIME type');

  CheckAckSent('No ACK sent');
  CheckEquals(Session.LocalSessionDescription,
              Self.LastSentAck.Body,
              'ACK answer');
  CheckEquals(Session.LocalMimeType,
              Self.LastSentAck.ContentType,
              'ACK answer MIME type');
end;

procedure TestTIdSipOutboundSession.TestCancelReceiveInviteOkBeforeCancelOk;
var
  Cancel: TIdSipRequest;
  Invite: TIdSipRequest;
begin
  //  ---          INVITE         --->
  // <---        100 Trying       ---
  //  ---          CANCEL         --->
  // <--- 200 OK (for the INVITE) ---
  //  ---           ACK           --->
  // <--- 200 OK (for the CANCEL) ---
  //  ---           BYE           --->
  // <---   200 OK (for the BYE)  ---

  Invite := TIdSipRequest.Create;
  try
    Cancel := TIdSipRequest.Create;
    try
      Invite.Assign(Self.LastSentRequest);
      Self.ReceiveTrying(Invite);

      Self.Session.Cancel;
      Cancel.Assign(Self.LastSentRequest);

      Self.MarkSentRequestCount;
      Self.ReceiveOk(Invite);
      Self.ReceiveOk(Cancel);

      Check(Self.OnEndedSessionFired,
            'Listeners not notified of end of session');
    finally
      Cancel.Free;
    end;
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestCircularRedirect;
begin
  //  ---   INVITE (original)   --->
  // <--- 302 Moved Temporarily ---
  //  ---          ACK          --->
  //  --- INVITE (redirect #1)  --->
  // <--- 302 Moved Temporarily ---
  //  ---          ACK          --->
  //  --- INVITE (redirect #2)  --->
  // <--- 302 Moved Temporarily ---
  //  ---          ACK          --->
  //  --- INVITE (redirect #1)  ---> again!
  // <--- 302 Moved Temporarily ---
  //  ---          ACK          --->

  Self.ReceiveMovedTemporarily('sip:foo@bar.org');
  Self.ReceiveMovedTemporarily('sip:bar@bar.org');

  Self.MarkSentRequestCount;
  Self.ReceiveMovedTemporarily('sip:foo@bar.org');
  CheckNoRequestSent('The session accepted the run-around');
end;

procedure TestTIdSipOutboundSession.TestDialogNotEstablishedOnTryingResponse;
var
  SentInvite: TIdSipRequest;
  Session:    TIdSipSession;
begin
  Self.MarkSentRequestCount;

  Session := Self.CreateAction as TIdSipSession;
  Check(not Session.DialogEstablished, 'Brand new session');

  CheckRequestSent('The INVITE wasn''t sent');
  SentInvite := Self.LastSentRequest;

  Self.ReceiveTryingWithNoToTag(SentInvite);
  Check(not Session.DialogEstablished,
        'Dialog established after receiving a 100 Trying');

  Self.ReceiveRinging(SentInvite);
  Check(Session.DialogEstablished,
        'Dialog not established after receiving a 180 Ringing');
end;

procedure TestTIdSipOutboundSession.TestDoubleRedirect;
begin
  //  ---   INVITE (original)   --->
  // <--- 302 Moved Temporarily ---
  //  ---          ACK          --->
  //  --- INVITE (redirect #1)  --->
  // <--- 302 Moved Temporarily ---
  //  ---          ACK          --->
  //  --- INVITE (redirect #2)  --->
  // <--- 302 Moved Temporarily ---
  //  ---          ACK          --->

  Self.MarkSentRequestCount;
  Self.ReceiveMovedTemporarily('sip:foo@bar.org');
  CheckRequestSent('No redirected INVITE #1 sent: ' + Self.FailReason);
  CheckEquals('sip:foo@bar.org',
              Self.LastSentRequest.RequestUri.Uri,
              'Request-URI of redirect #1');

  Self.MarkSentRequestCount;
  Self.ReceiveMovedTemporarily('sip:baz@quaax.org');
  CheckRequestSent('No redirected INVITE #2 sent: ' + Self.FailReason);
  CheckEquals('sip:baz@quaax.org',
              Self.LastSentRequest.RequestUri.Uri,
              'Request-URI of redirect #2');
end;

procedure TestTIdSipOutboundSession.TestEmptyTargetSetMeansTerminate;
begin
  Self.ReceiveMovedTemporarily('sip:foo@bar.org');
  Self.ReceiveForbidden;
  Check(Self.OnEndedSessionFired, 'Session didn''t end: ' + Self.FailReason);
end;

procedure TestTIdSipOutboundSession.TestEstablishedSessionSetsInitialRequestToTag;
begin
  Self.ReceiveRinging(Self.LastSentRequest);
  CheckEquals(Self.Dispatcher.Transport.LastResponse.ToHeader.Tag,
              Self.Session.InitialRequest.ToHeader.Tag,
              'Session.InitialRequest''s To tag not set');
end;

procedure TestTIdSipOutboundSession.TestGlobalFailureEndsSession;
var
  SessionCount: Integer;
begin
  SessionCount := Self.Core.SessionCount;

  Self.ReceiveRemoteDecline;

  Check(Self.OnEndedSessionFired,
        'No notification of ended session');

  Check(Self.Core.SessionCount < SessionCount,
        'Session not torn down because of a global failure');
end;

procedure TestTIdSipOutboundSession.TestHangUp;
begin
  Self.ReceiveOk(Self.LastSentRequest);

  Self.MarkSentRequestCount;
  Self.Session.Terminate;

  CheckRequestSent('No BYE sent');
  CheckEquals(MethodBye,
              Self.LastSentRequest.Method,
        'TU didn''t sent a BYE');
  Self.ReceiveOk(Self.LastSentRequest);
end;

procedure TestTIdSipOutboundSession.TestIsOutboundCall;
begin
  Check(Self.Session.IsOutboundCall,
        'Outbound session; IsOutboundCall');
end;

procedure TestTIdSipOutboundSession.TestMethod;
begin
  CheckEquals(MethodInvite,
              TIdSipOutboundSession.Method,
              'Outbound session; Method');
end;

procedure TestTIdSipOutboundSession.TestModifyUsesAuthentication;
var
  Invite: TIdSipRequest;
  Modify: TIdSipRequest;
begin
  // n, n+1, n+2, ..., n+m is the sequence of branch IDs generated by Self.Core.
  //  ---      INVITE      ---> (with branch n)
  // <--- 401 Unauthorized ---  (with branch n)
  //  ---      INVITE      ---> (with branch n+1)
  // <---      200 OK      ---  (with branch n+1)
  //  ---        ACK       ---> (with branch n+1)
  //  ---      INVITE      ---> (modify) (with branch n+2)

  Invite := TIdSipRequest.Create;
  try
    Self.MarkSentRequestCount;

    Self.ReceiveUnauthorized(WWWAuthenticateHeader, '');

    CheckRequestSent('No resend of INVITE with Authorization');
    Invite.Assign(Self.LastSentRequest);
    Check(Invite.HasAuthorization,
          'Resend INVITE has no Authorization header');

    Self.ReceiveOk(Self.LastSentRequest);
    Check(not Self.Session.IsEarly,
          'The UA didn''t update the InviteAction''s InitialRequest as a'
             + ' result of the authentication challenge.');

    Self.Session.Modify('', '');

    Modify := Self.LastSentRequest;
    Check(Modify.HasAuthorization,
          'No Authorization header');
    CheckEquals(Invite.FirstAuthorization.Value,
                Modify.FirstAuthorization.Value,
                'Authorization header');
    CheckEquals(Invite.CSeq.SequenceNo + 1,
                Modify.CSeq.SequenceNo,
                'Unexpected sequence number in the modify');
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestNetworkFailuresLookLikeSessionFailures;
begin
  Self.Dispatcher.Transport.FailWith := Exception;
  Self.ReceiveOk(Self.LastSentRequest);

  Check(Assigned(Self.ActionParam), 'OnNetworkFailure didn''t fire');
  Check(Self.ActionParam = Self.Session,
        'Session must signal the network error as _its_ error, not the '
      + 'Invite''s');
end;

procedure TestTIdSipOutboundSession.TestReceive1xxNotifiesListeners;
begin
  Self.ReceiveTrying(Self.LastSentRequest);

  Check(Self.OnProgressedSessionFired,
        'Listeners not notified of progress for initial INVITE');

  Self.EstablishSession(Self.Session);

  Self.OnProgressedSessionFired := false;
  Self.Session.Modify('', '');

  Self.ReceiveTrying(Self.LastSentRequest);

  Check(Self.OnProgressedSessionFired,
        'Listeners not notified of progress for modify INVITE');
end;

procedure TestTIdSipOutboundSession.TestReceive2xxSendsAck;
var
  Ack:    TIdSipRequest;
  Invite: TIdSipRequest;
  Ok:     TIdSipResponse;
begin
  Ok := Self.CreateRemoteOk(Self.LastSentRequest);
  try
    Self.MarkSentAckCount;
    Self.ReceiveResponse(Ok);

    CheckAckSent('Original ACK');

    Self.MarkSentAckCount;
    Self.ReceiveResponse(Ok);
    CheckAckSent('Retransmission');

    Ack := Self.LastSentAck;
    CheckEquals(MethodAck, Ack.Method, 'Unexpected method');
    Invite := Self.Session.InitialRequest;
    CheckEquals(Invite.CSeq.SequenceNo,
                Ack.CSeq.SequenceNo,
                'CSeq numerical portion');
    CheckEquals(MethodAck,
                Ack.CSeq.Method,
                'CSeq method');
  finally
    Ok.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestReceive3xxSendsNewInvite;
const
  NewAddress = 'sip:foo@bar.org';
var
  OriginalInvite: TIdSipRequest;
begin
  OriginalInvite := TIdSipRequest.Create;
  try
    OriginalInvite.Assign(Self.LastSentRequest);

    Self.MarkSentRequestCount;
    Self.ReceiveMovedPermanently(NewAddress);

    CheckRequestSent('Session didn''t send a new INVITE: ' + Self.FailReason);
  finally
    OriginalInvite.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestReceive3xxWithOneContact;
var
  Contact:     String;
  InviteCount: Integer;
  RequestUri:  TIdSipUri;
begin
  //  ---         INVITE        --->
  // <--- 302 Moved Temporarily ---
  //  ---          ACK          --->
  //  ---         INVITE        --->
  // <---     403 Forbidden     ---
  //  ---          ACK          --->

  Contact      := 'sip:foo@bar.org';
  InviteCount  := Self.Core.CountOf(MethodInvite);
  Self.MarkSentRequestCount;
  Self.ReceiveMovedTemporarily(Contact);

  CheckRequestSent('No new INVITE sent: ' + Self.FailReason);
  CheckEquals(InviteCount,
              Self.Core.CountOf(MethodInvite),
              'The Core should have one new INVITE and have destroyed one old one');

  RequestUri := Self.LastSentRequest.RequestUri;
  CheckEquals(Contact,
              RequestUri.Uri,
              'Request-URI');

  Self.ReceiveForbidden;
  Check(Self.Core.CountOf(MethodInvite) < InviteCount,
        'The Core didn''t destroy the second INVITE');
  Check(Self.OnEndedSessionFired,
        'Listeners not notified of failed call');
end;

procedure TestTIdSipOutboundSession.TestReceive3xxWithNoContacts;
var
  Redirect: TIdSipResponse;
begin
  Redirect := TIdSipResponse.InResponseTo(Self.LastSentRequest,
                                          SIPMovedPermanently);
  try
    Redirect.ToHeader.Tag := Self.Core.NextTag;
    Self.ReceiveResponse(Redirect);

    Check(Self.OnEndedSessionFired,
          'Session didn''t end despite a redirect with no Contact headers');
    CheckEquals(RedirectWithNoContacts, Self.ErrorCode, 'Stack reports wrong error code');
    CheckNotEquals('',
                   Self.Reason,
                   'Reason param not set');
  finally
    Redirect.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestReceiveFailureResponseAfterSessionEstablished;
var
  Invite: TIdSipRequest;
begin
  //  ---          INVITE         --->
  // <---          200 OK         ---
  //  ---           ACK           --->
  // <--- 503 Service Unavailable --- (in response to the INVITE!)

  // This situation should never arise: the remote end's sending a failure
  // response to a request it has already accepted. Still, I've seen it happen
  // once before...

  Invite := TIdSipRequest.Create;
  try
    Invite.Assign(Self.LastSentRequest);

    Self.MarkSentAckCount;
    Self.ReceiveOk(Invite);
    CheckAckSent('No ACK sent');

    Self.ReceiveServiceUnavailable(Invite);

    Check(not Self.Session.IsTerminated,
          'The Session received the response: the Transaction-User layer didn''t '
        + 'drop the message, or the Session Matched the request');
  finally
    Invite.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestReceiveFailureResponseNotifiesOnce;
var
  L:       TIdSipTestSessionListenerEndedCounter;
  Session: TIdSipOutboundSession;
begin
  Session := Self.Core.InviteModule.Call(Self.Destination, Self.SDP, SdpMimeType);
  L := TIdSipTestSessionListenerEndedCounter.Create;
  try
    Session.AddSessionListener(L);
    Session.Send;

    Self.ReceiveResponse(SIPDecline);

    CheckEquals(1, L.EndedNotificationCount, 'Not notified only once');
  finally
    L.Free;
  end;
end;

procedure TestTIdSipOutboundSession.TestReceiveFailureSetsReason;
begin
  Self.CreateAction;
  Self.ReceiveBusyHere(Self.LastSentRequest);

  Check(Self.OnEndedSessionFired,
        'OnEndedSession didn''t fire');
  CheckNotEquals('',
                 Self.Reason,
                 'Reason param not set');
end;

procedure TestTIdSipOutboundSession.TestReceiveFinalResponseSendsAck;
var
  I: Integer;
begin
  // Of course this works. That's because the transaction sends the ACK for a
  // non-2xx final response.
  for I := SIPRedirectionResponseClass to SIPGlobalFailureResponseClass do begin
    Self.MarkSentAckCount;

    Self.CreateAction;

    Self.ReceiveResponse(I*100);
    CheckAckSent('Session didn''t send an ACK to a final response, '
               + Self.LastSentResponse.Description);
  end;
end;

procedure TestTIdSipOutboundSession.TestRedirectAndAccept;
var
  Contact:     String;
  InviteCount: Integer;
  RequestUri:  TIdSipUri;
begin
  //  ---         INVITE        --->
  // <--- 302 Moved Temporarily ---
  //  ---          ACK          --->
  //  ---         INVITE        --->
  // <---         200 OK        ---
  //  ---          ACK          --->

  Contact      := 'sip:foo@bar.org';
  InviteCount  := Self.Core.CountOf(MethodInvite);
  Self.MarkSentRequestCount;
  Self.ReceiveMovedTemporarily(Contact);

  CheckRequestSent('No new INVITE sent: ' + Self.FailReason);
  CheckEquals(InviteCount,
              Self.Core.CountOf(MethodInvite),
              'The Core should have one new INVITE and have destroyed one old one');

  RequestUri := Self.LastSentRequest.RequestUri;
  CheckEquals(Contact,
              RequestUri.Uri,
              'Request-URI');

  Self.ReceiveOk(Self.LastSentRequest);

  Check(Self.OnEstablishedSessionFired,
        'Listeners not notified of a successful call');
end;

procedure TestTIdSipOutboundSession.TestRedirectMultipleOks;
const
  FirstInvite    = 0;
  FirstRedirect  = 1;
  SecondRedirect = 2;
  ThirdRedirect  = 3;
  Bye            = 4;
  Cancel         = 5;
var
  Contacts: array of String;
begin
  //                               Request number:
  //  ---       INVITE        ---> #0
  // <---   302 (foo,bar,baz) ---
  //  ---        ACK          --->
  //  ---     INVITE(foo)     ---> #1
  //  ---     INVITE(bar)     ---> #2
  //  ---     INVITE(baz)     ---> #3
  // <---      200 (bar)      ---
  //  ---        ACK          --->
  // <---      200 (foo)      ---
  //  ---        ACK          --->
  //  ---        BYE          ---> #4 (because we've already established a session)
  // <---    200 (foo,BYE)    ---
  // <---      100 (baz)      ---
  //  ---       CANCEL        ---> #5
  // <---  200 (baz,CANCEL)   ---

  SetLength(Contacts, 3);
  Contacts[0] := 'sip:foo@bar.org';
  Contacts[1] := 'sip:bar@bar.org';
  Contacts[2] := 'sip:baz@bar.org';

  Self.MarkSentRequestCount;
  Self.ReceiveMovedTemporarily(Contacts);

  // ARG! Why do they make Length return an INTEGER? And WHY Abs() too?
  CheckEquals(Self.RequestCount + Cardinal(Length(Contacts)),
              Self.Dispatcher.Transport.SentRequestCount,
              'Session didn''t attempt to contact all Contacts: ' + Self.FailReason);

  Self.MarkSentRequestCount;
  Self.ReceiveOkFrom(Self.SentRequestAt(SecondRedirect), Contacts[1]);
  Self.ReceiveOkFrom(Self.SentRequestAt(FirstRedirect), Contacts[0]);
  Self.ReceiveTryingFrom(Self.SentRequestAt(ThirdRedirect), Contacts[2]);

  // We expect a BYE in response to the 1st UA's 2xx and a CANCEL to the 2nd
  // UA's 1xx.

  // ARG! Why do they make Length return an INTEGER? And WHY Abs() too?
  CheckEquals(Self.RequestCount + Cardinal(Length(Contacts) - 1),
              Self.Dispatcher.Transport.SentRequestCount,
              'Session didn''t try to kill all but one of the redirected INVITEs');

  CheckRequestSent('We expect the session to send _something_');
  CheckEquals(MethodBye,
              Self.SentRequestAt(Bye).Method,
              'Unexpected first request sent');
  CheckEquals(Contacts[0],
              Self.SentRequestAt(Bye).RequestUri.Uri,
              'Unexpected target for the first BYE');
  CheckEquals(MethodCancel,
              Self.SentRequestAt(Cancel).Method,
              'Unexpected second request sent');
  CheckEquals(Contacts[2],
              Self.SentRequestAt(Cancel).RequestUri.Uri,
              'Unexpected target for the second BYE');
end;

procedure TestTIdSipOutboundSession.TestRedirectNoMoreTargets;
var
  Contacts: array of String;
begin
  //                                           Request number:
  //  ---              INVITE             ---> #0
  // <---          302 (foo,bar)          ---
  //  ---               ACK               --->
  //  ---           INVITE (foo)          ---> #1
  //  ---           INVITE (bar)          ---> #2
  // <--- 302 (from foo, referencing bar) ---
  // <--- 302 (from bar, referencing foo) ---
  //  ---          ACK (to foo)           --->
  //  ---          ACK (to bar)           --->

  SetLength(Contacts, 2);
  Contacts[0] := 'sip:foo@bar.org';
  Contacts[1] := 'sip:bar@bar.org';

  Self.ReceiveMovedTemporarily(Contacts);

  Check(Self.SentRequestCount >= 3,
        'Not enough requests sent: 1 + 2 INVITEs: ' + Self.FailReason);

  Self.ReceiveMovedTemporarily(Self.SentRequestAt(1), Contacts[1]);
  Self.ReceiveMovedTemporarily(Self.SentRequestAt(2), Contacts[0]);

  Check(Self.OnEndedSessionFired,
        'Session didn''t notify listeners of ended session');
  CheckEquals(RedirectWithNoMoreTargets, Self.ErrorCode,
              'Session reported wrong error code for no more redirect targets');
  CheckNotEquals('',
                 Self.Reason,
                 'Reason param not set');
end;

procedure TestTIdSipOutboundSession.TestRedirectWithMultipleContacts;
var
  Contacts: array of String;
begin
  SetLength(Contacts, 2);
  Contacts[0] := 'sip:foo@bar.org';
  Contacts[1] := 'sip:bar@bar.org';

  Self.MarkSentRequestCount;

  Self.ReceiveMovedTemporarily(Contacts);

  // ARG! Why do they make Length return an INTEGER? And WHY Abs() too?
  CheckEquals(Self.RequestCount + Cardinal(Length(Contacts)),
              Self.Dispatcher.Transport.SentRequestCount,
              'Session didn''t attempt to contact all Contacts: ' + Self.FailReason);
end;

procedure TestTIdSipOutboundSession.TestRedirectWithNoSuccess;
var
  Contacts: array of String;
begin
  //                             Request number:
  //  ---       INVITE      ---> #0
  // <---   302 (foo,bar)   ---
  //  ---        ACK        --->
  //  ---    INVITE (foo)   ---> #1
  //  ---    INVITE (bar)   ---> #2
  // <---     486 (foo)     ---
  // <---     486 (bar)     ---
  //  ---    ACK (to foo)   --->
  //  ---    ACK (to bar)   --->

  SetLength(Contacts, 2);
  Contacts[0] := 'sip:foo@bar.org';
  Contacts[1] := 'sip:bar@bar.org';

  Self.ReceiveMovedTemporarily(Contacts);

  Check(Self.SentRequestCount >= 3,
        'Not enough requests sent: 1 + 2 INVITEs: ' + Self.FailReason);

  Self.ReceiveBusyHere(Self.SentRequestAt(1));
  Self.ReceiveBusyHere(Self.SentRequestAt(2));

  Check(Self.OnEndedSessionFired,
        'Session didn''t notify listeners of ended session');
  CheckEquals(RedirectWithNoSuccess, Self.ErrorCode,
              'Session reported wrong error code for no successful rings');
  CheckNotEquals('',
                 Self.Reason,
                 'Reason param not set');
end;

procedure TestTIdSipOutboundSession.TestSendSetsInitialRequest;
var
  Session: TIdSipAction;
begin
  Session := Self.CreateAction;
  Check(Session.InitialRequest.Equals(Self.LastSentRequest),
        'Sending the session didn''t set the session''s InitialRequest');
end;

procedure TestTIdSipOutboundSession.TestTerminateDuringRedirect;
var
  Contacts: array of String;
  I:        Integer;
begin
  //                             Request count
  //  ---       INVITE      ---> #0
  // <---   302 (foo,bar)   ---
  //  ---        ACK        --->
  //  ---    INVITE (foo)   ---> #1
  //  ---    INVITE (bar)   ---> #2
  // <---     100 (foo)     --- (we receive 100s so the InviteActions will send CANCELs immediately)
  // <---     100 (bar)     ---
  //  ---    CANCEL (foo)   ---> #3
  // <--- 200 (foo, CANCEL) ---
  //  ---    CANCEL (bar)   ---> #4
  // <--- 200 (bar, CANCEL) ---

  SetLength(Contacts, 2);
  Contacts[0] := 'sip:foo@bar.org';
  Contacts[1] := 'sip:bar@bar.org';

  Self.ReceiveMovedTemporarily(Contacts);

  Check(Self.SentRequestCount >= 3,
        'Not enough requests sent: 1 + 2 INVITEs: ' + Self.FailReason);

  Self.ReceiveTrying(Self.SentRequestAt(1));
  Self.ReceiveTrying(Self.SentRequestAt(2));

  Self.MarkSentRequestCount;
  Self.Session.Terminate;

  // ARG! Why do they make Length return an INTEGER? And WHY Abs() too?
  CheckEquals(Self.RequestCount + Cardinal(Length(Contacts)),
              Self.Dispatcher.Transport.SentRequestCount,
              'Session didn''t attempt to terminate all INVITEs');

  Check(Self.SentRequestCount >= 5,
        'Not enough requests sent: 1 + 2 INVITEs, 2 CANCELs');

  for I := 0 to 1 do begin
    CheckEquals(Contacts[I],
                Self.SentRequestAt(I + 3).RequestUri.Uri,
                'CANCEL to ' + Contacts[I]);
    CheckEquals(MethodCancel,
                Self.SentRequestAt(I + 3).Method,
                'Request method to ' + Contacts[I]);
  end;
end;

procedure TestTIdSipOutboundSession.TestTerminateEstablishedSession;
var
  SessionCount: Integer;
begin
  Self.Dispatcher.Transport.WriteLog := true;
  Self.ReceiveOk(Self.LastSentRequest);

  Self.MarkSentRequestCount;
  SessionCount := Self.Core.SessionCount;
  Self.Session.Terminate;

  CheckRequestSent('No request sent');
  CheckEquals(MethodBye,
              Self.LastSentRequest.Method,
              'Session didn''t terminate with a BYE');

  Check(Self.Core.SessionCount < SessionCount,
        'Session not marked as terminated');
end;

procedure TestTIdSipOutboundSession.TestTerminateNetworkFailure;
var
  SessionCount: Integer;
begin
  Self.ReceiveOk(Self.LastSentRequest);

  Self.Dispatcher.Transport.FailWith := EIdConnectTimeout;

  SessionCount := Self.Core.SessionCount;
  Self.Session.Terminate;

  Check(Self.Core.SessionCount < SessionCount,
        'Session not marked as terminated');
  CheckEquals(MethodBye,
              Self.Dispatcher.Transport.LastRequest.Method,
              'Last request we attempted to send');
end;

procedure TestTIdSipOutboundSession.TestTerminateUnestablishedSession;
var
  Invite:            TIdSipRequest;
  Request:           TIdSipRequest;
  RequestTerminated: TIdSipResponse;
  SessionCount:      Integer;
begin
  // When you Terminate a Session, the Session should attempt to CANCEL its
  // initial INVITE (if it hasn't yet received a final response).

  Self.MarkSentRequestCount;

  Invite := TIdSipRequest.Create;
  try
    Invite.Assign(Self.LastSentRequest);

    // We don't actually send CANCELs when we've not received a provisional
    // response.
    Self.ReceiveRinging(Invite);

    RequestTerminated := TIdSipResponse.InResponseTo(Invite, SIPRequestTerminated);
    try
      RequestTerminated.ToHeader.Tag := Self.Session.Dialog.ID.RemoteTag;

      SessionCount := Self.Core.SessionCount;
      Self.Session.Terminate;

      CheckRequestSent('no CANCEL sent');

      Request := Self.LastSentRequest;
      CheckEquals(MethodCancel,
                  Request.Method,
                  'Session didn''t terminate with a CANCEL');

      Self.ReceiveResponse(RequestTerminated);

      Check(Self.Core.SessionCount < SessionCount,
            'Session not marked as terminated');
    finally
      RequestTerminated.Free;
    end;
  finally
    Invite.Free;
  end;
end;

//******************************************************************************
//* TInviteMethodTestCase                                                      *
//******************************************************************************
//* TInviteMethodTestCase Public methods ***************************************

procedure TInviteMethodTestCase.SetUp;
var
  Nowhere: TIdSipAddressHeader;
begin
  inherited SetUp;

  Nowhere := TIdSipAddressHeader.Create;
  try
    Self.Invite := TIdSipOutboundInvite.Create(Self.UA);
  finally
    Nowhere.Free;
  end;

  Self.Listener := TIdSipTestInviteListener.Create;
end;

procedure TInviteMethodTestCase.TearDown;
begin
  Self.Listener.Free;
  Self.Invite.Free;

  inherited TearDown;
end;

//******************************************************************************
//* TestTIdSipInviteCallProgressMethod                                         *
//******************************************************************************
//* TestTIdSipInviteCallProgressMethod Public methods **************************

procedure TestTIdSipInviteCallProgressMethod.SetUp;
begin
  inherited SetUp;

  Self.Method := TIdSipInviteCallProgressMethod.Create;
  Self.Method.Invite   := Self.Invite;
  Self.Method.Response := Self.Response;
end;

procedure TestTIdSipInviteCallProgressMethod.TearDown;
begin
  Self.Method.Free;

  inherited TearDown;
end;

//* TestTIdSipInviteCallProgressMethod Published methods ***********************

procedure TestTIdSipInviteCallProgressMethod.TestRun;
begin
  Self.Method.Run(Self.Listener);

  Check(Self.Listener.CallProgress,
        'Listener not notified');
  Check(Self.Invite = Self.Listener.InviteAgentParam,
        'InviteAgent param');
  Check(Self.Response = Self.Listener.ResponseParam,
        'Response param');
end;

//******************************************************************************
//* TestTIdSipInboundInviteFailureMethod                                       *
//******************************************************************************
//* TestTIdSipInboundInviteFailureMethod Public methods ************************

procedure TestTIdSipInboundInviteFailureMethod.SetUp;
begin
  inherited SetUp;

  Self.Invite := TIdSipTestResources.CreateBasicRequest;

  Self.Method := TIdSipInboundInviteFailureMethod.Create;
  Self.Method.Invite := TIdSipInboundInvite.CreateInbound(Self.UA, Self.Invite, false);
end;

procedure TestTIdSipInboundInviteFailureMethod.TearDown;
begin
  Self.Method.Invite.Free;
  Self.Method.Free;
  Self.Invite.Free;

  inherited TearDown;
end;

//* TestTIdSipInboundInviteFailureMethod Published methods *********************

procedure TestTIdSipInboundInviteFailureMethod.TestRun;
var
  Listener: TIdSipTestInboundInviteListener;
begin
  Listener := TIdSipTestInboundInviteListener.Create;
  try
    Self.Method.Run(Listener);

    Check(Listener.Failed, 'Listener not notified');
    Check(Self.Method.Invite = Listener.InviteAgentParam,
          'InviteAgent param');
  finally
    Listener.Free;
  end;
end;

//******************************************************************************
//* TestTIdSipInviteDialogEstablishedMethod                                    *
//******************************************************************************
//* TestTIdSipInviteDialogEstablishedMethod Public methods *********************

procedure TestTIdSipInviteDialogEstablishedMethod.SetUp;
var
  Nowhere: TIdSipAddressHeader;
begin
  inherited SetUp;

  Self.Method := TIdSipInviteDialogEstablishedMethod.Create;

  Nowhere := TIdSipAddressHeader.Create;
  try
    Self.Method.Invite := TIdSipOutboundInvite.Create(Self.UA);
    Self.Method.Dialog := TIdSipDialog.Create;
  finally
    Nowhere.Free;
  end;
end;

procedure TestTIdSipInviteDialogEstablishedMethod.TearDown;
begin
  Self.Method.Invite.Free;
  Self.Method.Dialog.Free;
  Self.Method.Free;

  inherited TearDown;
end;

//* TestTIdSipInviteDialogEstablishedMethod Published methods ******************

procedure TestTIdSipInviteDialogEstablishedMethod.TestRun;
var
  Listener: TIdSipTestInviteListener;
begin
  Listener := TIdSipTestInviteListener.Create;
  try
    Self.Method.Run(Listener);

    Check(Listener.DialogEstablished, 'Listener not notified');
    Check(Self.Method.Invite = Listener.InviteAgentParam,
          'InviteAgent param');
    Check(Self.Method.Response = Listener.ResponseParam,
          'Response param');
  finally
    Listener.Free;
  end;
end;

//******************************************************************************
//* TestInviteMethod                                                           *
//******************************************************************************
//* TestInviteMethod Public methods ********************************************

procedure TestInviteMethod.SetUp;

begin
  inherited SetUp;

  Self.Invite   := Self.UA.AddOutboundAction(TIdSipOutboundInitialInvite) as TIdSipOutboundInitialInvite;
  Self.Listener := TIdSipTestInviteListener.Create;
end;

procedure TestInviteMethod.TearDown;
begin
  Self.Listener.Free;
  // Self.UA owns Self.Invite!

  inherited TearDown;
end;

//******************************************************************************
//* TestTIdSipInviteFailureMethod                                              *
//******************************************************************************
//* TestTIdSipInviteFailureMethod Public methods *******************************

procedure TestTIdSipInviteFailureMethod.SetUp;
begin
  inherited SetUp;

  Self.Method := TIdSipInviteFailureMethod.Create;

  Self.Method.Invite   := Self.Invite;
  Self.Method.Reason   := 'none';
  Self.Method.Response := Self.Response;
end;

procedure TestTIdSipInviteFailureMethod.TearDown;
begin
  Self.Method.Free;

  inherited TearDown;
end;

//* TestTIdSipInviteFailureMethod Published methods ****************************

procedure TestTIdSipInviteFailureMethod.TestRun;
begin
  Self.Method.Run(Self.Listener);

  Check(Self.Listener.Failure, 'Listener not notified');
  Check(Self.Method.Invite = Self.Listener.InviteAgentParam,
        'InviteAgent param');
  Check(Self.Method.Response = Self.Listener.ResponseParam,
        'Response param');
  CheckEquals(Self.Method.Reason,
              Self.Listener.ReasonParam,
              'Reason param');
end;

//******************************************************************************
//* TestTIdSipInviteRedirectMethod                                             *
//******************************************************************************
//* TestTIdSipInviteRedirectMethod Public methods ******************************

procedure TestTIdSipInviteRedirectMethod.SetUp;
begin
  inherited SetUp;

  Self.Method := TIdSipInviteRedirectMethod.Create;

  Self.Method.Invite   := Self.Invite;
  Self.Method.Response := Self.Response;
end;

procedure TestTIdSipInviteRedirectMethod.TearDown;
begin
  Self.Method.Free;

  inherited TearDown;
end;

//* TestTIdSipInviteRedirectMethod Published methods ***************************

procedure TestTIdSipInviteRedirectMethod.Run;
begin
  Self.Method.Run(Self.Listener);

  Check(Self.Listener.Redirect, 'Listener not notified');
  Check(Self.Method.Invite = Self.Listener.InviteAgentParam,
        'Invite param');
  Check(Self.Method.Response = Self.Listener.ResponseParam,
        'Response param');
end;

//******************************************************************************
//* TestTIdSipInviteSuccessMethod                                              *
//******************************************************************************
//* TestTIdSipInviteSuccessMethod Public methods *******************************

procedure TestTIdSipInviteSuccessMethod.SetUp;
begin
  inherited SetUp;

  Self.Method := TIdSipInviteSuccessMethod.Create;

  Self.Method.Invite   := Self.Invite;
  Self.Method.Response := Self.Response;
end;

procedure TestTIdSipInviteSuccessMethod.TearDown;
begin
  Self.Method.Free;

  inherited TearDown;
end;

//* TestTIdSipInviteSuccessMethod Published methods ****************************

procedure TestTIdSipInviteSuccessMethod.TestRun;
begin
  Self.Method.Run(Self.Listener);

  Check(Self.Listener.Success, 'Listener not notified');
  Check(Self.Method.Invite = Self.Listener.InviteAgentParam,
        'InviteAgent param');
  Check(Self.Method.Response = Self.Listener.ResponseParam,
        'Response param');
end;

//******************************************************************************
//* TestSessionMethod                                                          *
//******************************************************************************
//* TestSessionMethod Public methods *******************************************

procedure TestSessionMethod.SetUp;
begin
  inherited SetUp;

  Self.Listener := TIdSipTestSessionListener.Create;
  Self.Session  := TIdSipOutboundSession.Create(Self.UA);
end;

procedure TestSessionMethod.TearDown;
begin
  Self.Session.Free;
  Self.Listener.Free;

  inherited TearDown;
end;

//******************************************************************************
//* TestTIdSipEndedSessionMethod                                               *
//******************************************************************************
//* TestTIdSipEndedSessionMethod Public methods ********************************

procedure TestTIdSipEndedSessionMethod.SetUp;
const
  ArbValue = 42;
begin
  inherited SetUp;

  Self.Method := TIdSipEndedSessionMethod.Create;

  Self.Method.Session   := Self.Session;
  Self.Method.ErrorCode := ArbValue;
  Self.Method.Reason    := 'arbitrary reason';
end;

procedure TestTIdSipEndedSessionMethod.TearDown;
begin
  Self.Method.Free;

  inherited TearDown;
end;

//* TestTIdSipEndedSessionMethod Published methods *****************************

procedure TestTIdSipEndedSessionMethod.TestRun;
begin
  Self.Method.Run(Self.Listener);

  Check(Self.Method.Session = Self.Listener.SessionParam,
        'Session param');
  CheckEquals(Self.Method.ErrorCode,
              Self.Listener.ErrorCodeParam,
              'ErrorCode param');
  CheckEquals(Self.Method.Reason,
              Self.Listener.ReasonParam,
              'Reason param');
end;

//******************************************************************************
//* TestTIdSipEstablishedSessionMethod                                         *
//******************************************************************************
//* TestTIdSipEstablishedSessionMethod Public methods **************************

procedure TestTIdSipEstablishedSessionMethod.SetUp;
begin
  inherited SetUp;

  Self.Method := TIdSipEstablishedSessionMethod.Create;

  Self.Method.RemoteSessionDescription := 'I describe a session''s media';
  Self.Method.MimeType                 := 'text/plain';
  Self.Method.Session                  := Self.Session;
end;

procedure TestTIdSipEstablishedSessionMethod.TearDown;
begin
  Self.Method.Free;

  inherited TearDown;
end;

//* TestTIdSipEstablishedSessionMethod Published methods ***********************

procedure TestTIdSipEstablishedSessionMethod.TestRun;
begin
  Self.Method.Run(Self.Listener);

  Check(Self.Method.Session = Self.Listener.SessionParam,
        'Session param');
  CheckEquals(Self.Method.MimeType,
              Self.Listener.MimeType,
              'MimeType param');
  CheckEquals(Self.Method.RemoteSessionDescription,
              Self.Listener.RemoteSessionDescription,
              'RemoteSessionDescription param');
end;

//******************************************************************************
//* TestTIdSipModifiedSessionMethod                                            *
//******************************************************************************
//* TestTIdSipModifiedSessionMethod Public methods *****************************

procedure TestTIdSipModifiedSessionMethod.SetUp;
begin
  inherited SetUp;

  Self.Answer := TIdSipResponse.Create;

  Self.Method := TIdSipModifiedSessionMethod.Create;

  Self.Method.Session := Self.Session;
  Self.Method.Answer  := Self.Answer;
end;

procedure TestTIdSipModifiedSessionMethod.TearDown;
begin
  Self.Method.Free;
  Self.Answer.Free;

  inherited TearDown;
end;

//* TestTIdSipModifiedSessionMethod Published methods **************************

procedure TestTIdSipModifiedSessionMethod.TestRun;
begin
  Self.Method.Run(Self.Listener);

  Check(Self.Method.Answer = Self.Listener.AnswerParam,
        'Answer param');
  Check(Self.Method.Session = Self.Listener.SessionParam,
        'Session param');
end;

//******************************************************************************
//* TestTIdSipSessionModifySessionMethod                                       *
//******************************************************************************
//* TestTIdSipSessionModifySessionMethod Public methods ************************

procedure TestTIdSipSessionModifySessionMethod.SetUp;
var
  Invite: TIdSipRequest;
begin
  inherited SetUp;

  Self.Method := TIdSipSessionModifySessionMethod.Create;

  Invite := TIdSipTestResources.CreateBasicRequest;
  try
    Self.Session := Self.UA.InviteModule.Call(Invite.ToHeader, '', '');

    Self.Method.RemoteSessionDescription := Invite.Body;
    Self.Method.Session                  := Self.Session;
    Self.Method.MimeType                 := Invite.ContentType;
  finally
    Invite.Free;
  end;
end;

//* TestTIdSipSessionModifySessionMethod Published methods *********************

procedure TestTIdSipSessionModifySessionMethod.TestRun;
begin
  Self.Method.Run(Self.Listener);

  Check(Self.Method.Session = Self.Listener.SessionParam,
        'Modify param');
  CheckEquals(Self.Method.MimeType,
              Self.Listener.MimeType,
              'MimeType');
  CheckEquals(Self.Method.RemoteSessionDescription,
              Self.Listener.RemoteSessionDescription,
              'RemoteSessionDescription');
end;

//******************************************************************************
//* TestTIdSipProgressedSessionMethod                                          *
//******************************************************************************
//* TestTIdSipProgressedSessionMethod Public methods ***************************

procedure TestTIdSipProgressedSessionMethod.SetUp;
begin
  inherited SetUp;

  Self.Progress := TIdSipResponse.Create;

  Self.Method := TIdSipProgressedSessionMethod.Create;

  Self.Method.Progress := Self.Progress;
  Self.Method.Session  := Self.Session;
end;

procedure TestTIdSipProgressedSessionMethod.TearDown;
begin
  Self.Method.Free;
  Self.Progress.Free;

  inherited TearDown;
end;

//* TestTIdSipProgressedSessionMethod Published methods ************************

procedure TestTIdSipProgressedSessionMethod.TestRun;
begin
  Self.Method.Run(Self.Listener);

  Check(Self.Method.Progress = Self.Listener.ProgressParam,
        'Progress param');
  Check(Self.Method.Session = Self.Listener.SessionParam,
        'Session param');
end;

initialization
  RegisterTest('User Agent tests', Suite);
end.