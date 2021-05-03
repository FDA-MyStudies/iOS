/*
 License Agreement for FDA My Studies
Copyright © 2017-2019 Harvard Pilgrim Health Care Institute (HPHCI) and its Contributors. Permission is
hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the &quot;Software&quot;), to deal in the Software without restriction, including without
limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
Software, and to permit persons to whom the Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.
Funding Source: Food and Drug Administration (“Funding Agency”) effective 18 September 2014 as
Contract no. HHSF22320140030I/HHSF22301006T (the “Prime Contract”).
THE SOFTWARE IS PROVIDED &quot;AS IS&quot;, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

// MARK:- Alert Constants

let kTermsAndConditionLink = "http://www.google.com"
let kPrivacyPolicyLink = "http://www.facebook.com"
let kNavigationTitleTerms = NSLocalizedStrings("TERMS", comment: "")
let kNavigationTitlePrivacyPolicy = NSLocalizedStrings("PRIVACY POLICY", comment: "")
let kProceedTitle = NSLocalizedStrings("Proceed", comment: "")

let kAlertPleaseEnterValidValue = NSLocalizedStrings("Please Enter Valid Value", comment: "")

//Used for corner radius Color for sign in , sign up , forgot password etc screens
let kUicolorForButtonBackground = UIColor.init(red: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0).cgColor

let kUicolorForCancelBackground = UIColor.init(red: 140/255.0, green: 149/255.0, blue: 163/255.0, alpha: 1.0).cgColor

let kUIColorForSubmitButtonBackground = UIColor.init(red: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0)

let NoNetworkErrorCode = -101
let CouldNotConnectToServerCode = -1001
var bundleKey: UInt8 = 0

//Display Constants
let kTitleError = NSLocalizedStrings("Error", comment: "")
let kTitleMessage = NSLocalizedStrings("Message", comment: "")
let kImportantNoteMessage = NSLocalizedStrings("Important Note", comment: "")
let kTitleOk = NSLocalizedStrings("Ok", comment: "")
let kTitleOKCapital = NSLocalizedStrings("OK", comment: "")
let kTitleCancel = NSLocalizedStrings("Cancel", comment: "")
let kTitleDeleteAccount = NSLocalizedStrings("Delete Account", comment: "")
let kRegistrationInfoMessage = NSLocalizedStrings("Registration (or sign up) for the app  is requested only to provide you with a seamless experience of using the app. Your registration information does not become part of the data collected for any study(ies) housed in the app. Each study has its own consent process and your data for the study will not be collected without you providing your informed consent prior to joining the study.", comment: "")

let kDeleteAccountConfirmationMessage = NSLocalizedStrings("Are you sure you wish to permanently delete your #APPNAME# account? You will need to register again if you wish to join a study.", comment: "")
let kMessageAccountDeletedSuccess = NSLocalizedStrings("Account has been deleted", comment: "")
let kMessageAppNotificationOffRemainder = NSLocalizedStrings("Stay up-to-date! Turn ON notifications and reminders in app and phone settings to get notified about study activity in a timely manner.", comment: "")
let kAuthenticationRequired = NSLocalizedStrings("Authentication Required", comment: "")

// MARK:- Signin Constants
let kSignInTitleText = NSLocalizedStrings("SIGN IN", comment: "")
let kWhyRegisterText = NSLocalizedStrings("Why Register?", comment: "")
let kSignInTableViewCellIdentifier = "DetailsCell"


// MARK:- ForgotPassword Constants
let kForgotPasswordTitleText = NSLocalizedStrings("PASSWORD HELP", comment: "")
let kForgotPasswordResponseMessage = NSLocalizedStrings("We have sent a temporary password to your registered email. Please login with temporary password and change your password.", comment: "")

// MARK:- SignUp Constants
let kSignUpTitleText = NSLocalizedStrings("SIGN UP", comment: "")
let kAgreeToTermsAndConditionsText = NSLocalizedStrings("I Agree to the Terms and Privacy Policy", comment: "")
let kTermsText = NSLocalizedStrings("Terms", comment: "")
let kPrivacyPolicyText = NSLocalizedStrings("Privacy Policy", comment: "")
let kSignUpTableViewCellIdentifier = "CommonDetailsCell"
let kNo = NSLocalizedStrings("No", comment: "")
let kYes = NSLocalizedStrings("Yes", comment: "")

// MARK:- NOTIFICATIONS Constants
let kNotificationsTitleText = NSLocalizedStrings("NOTIFICATIONS", comment: "")
let kNotificationTableViewCellIdentifier = "NotificationCell"


// MARK:- Validations Message during signup and sign in process

let kMessageFirstNameBlank = NSLocalizedStrings("Please enter your first name.", comment: "")
let kMessageLastNameBlank = NSLocalizedStrings("Please enter your last name.", comment: "")
let kMessageEmailBlank = NSLocalizedStrings("Please enter your email address.", comment: "")
let kMessagePasswordBlank = NSLocalizedStrings("Please enter your password.", comment: "")

let kMessageCurrentPasswordBlank = NSLocalizedStrings("Please enter your current password.", comment: "")

let kMessageProfileConfirmPasswordBlank = NSLocalizedStrings("Please confirm your password.", comment: "")
let kMessageConfirmPasswordBlank = NSLocalizedStrings("Please confirm the password.", comment: "")

let kMessagePasswordMatchingToOtherFeilds = NSLocalizedStrings("Your password should not match with email id", comment: "")


let kMessageValidEmail = NSLocalizedStrings("Please enter valid email address.", comment: "")

let kMessageValidatePasswords = NSLocalizedStrings("The Password and Confirm password fields don't match.", comment: "")
let kMessageProfileValidatePasswords = NSLocalizedStrings("New password and confirm password fields don't match.", comment: "")


let kMessageValidatePasswordCharacters = NSLocalizedStrings("Password should have minimum of 8 characters.", comment: "")
let kMessageValidatePasswordComplexity = NSLocalizedStrings("Your password MUST be 8-64 characters and contain each of the following: An uppercase letter, A lower case letter, A number 0-9, a special character: \\ ! # % & ‘ () * + , - . : < > = ? @ [] ^ _ { } | ~ *", comment: "")
let kMessageAgreeToTermsAndConditions = NSLocalizedStrings("Please agree to terms and conditions.", comment: "")

let kMessageNewPasswordBlank = NSLocalizedStrings("Please enter your new password.", comment: "")
let kMessageValidateChangePassword = NSLocalizedStrings("New password and old password are same.", comment: "")
let kMessageRelationship = NSLocalizedStrings("Please enter your relationship to the participant.", comment: "")

// MARK:- ChangePassword Constants
let kChangePasswordTitleText = NSLocalizedStrings("CHANGE PASSWORD", comment: "")
let kCreatePasswordTitleText = NSLocalizedStrings("CREATE PASSWORD", comment: "")
let kChangePawwordCellIdentifer = "changePasswordCell"
let kChangePasswordResponseMessage = NSLocalizedStrings("Your password has been changed successfully", comment: "")

let kMessageAllFieldsAreEmpty = NSLocalizedStrings("Please enter all the fields", comment: "")
let kMessageValidFirstName = NSLocalizedStrings("Please enter valid first name. Please use letters(length:1 - 100 characters).", comment: "")
let kMessageValidLastName = NSLocalizedStrings("Please enter valid last name. Please use letters(length:1 - 100 characters).", comment: "")

let kMessageValidateOldAndNewPasswords = NSLocalizedStrings("Old password and New password should not be same.", comment: "")

// MARK:-VerificationController
let kMessageVerificationCodeEmpty = NSLocalizedStrings("Please enter valid Verification Code", comment: "")

// MARK:- FeedbackviewController constants
let kFeedbackTableViewCellIdentifier1 = "FeedbackCellFirst"
let kFeedbackTableViewCellIdentifier2 = "FeedbackCellSecond"
let kMessageFeedbackSubmittedSuccessfuly = NSLocalizedStrings("Thank you for providing feedback. Your gesture is appreciated.", comment: "")

// MARK:- ContactUsviewController constants
let kContactUsTableViewCellIdentifier = "ContactUsCell"
let kMessageSubjectBlankCheck = NSLocalizedStrings("Please enter subject", comment: "")
let kMessageMessageBlankCheck = NSLocalizedStrings("Please enter message", comment: "")
let kMessageContactedSuccessfuly = NSLocalizedStrings("Thank you for contacting us. We will get back to you on your email address at the earliest.", comment: "")
let kMessageTextViewPlaceHolder = ""


// MARK:- ActivitiesViewController constants
let kBackgroundTableViewColor = UIColor.init(red: 216/255.0, green: 227/255.0, blue: 230/255.0, alpha: 1)
let kActivitiesTableViewCell = "ActivitiesCell"
let kActivitiesTableViewScheduledCell = "ActivitiesCellScheduled"

let kYellowColor = UIColor.init(red: 245/255.0, green: 175/255.0, blue: 55/255.0, alpha: 1.0)
let kBlueColor = UIColor.init(red: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0)
let kGreenColor = UIColor.init(red: 76/255.0, green: 175/255.0, blue: 80/255.0, alpha: 1.0)


let kResumeSpaces = NSLocalizedStrings("  Resume  ", comment: "")
let kStartSpaces = NSLocalizedStrings("  Start  ", comment: "")
let kCompletedSpaces = NSLocalizedStrings("  Completed  ", comment: "")
let kInCompletedSpaces = NSLocalizedStrings("  Incompleted  ", comment: "")
let kExpiredSpaces = NSLocalizedStrings("  Expired  ", comment: "")
let kEnterHere = NSLocalizedStrings("enter here", comment: "")

// MARK:- ResourcesViewController constants
let kResourcesTableViewCell = "ResourcesCell"
var kNewResourceAvailable: String = NSLocalizedStrings("New Resource Available", comment: "")

// MARK:- StudyDashboardViewController constants
let kWelcomeTableViewCell = "welcomeCell"
let kStudyActivityTableViewCell = "studyActivityCell"
let kPercentageTableViewCell = "percentageCell"
let kActivityTableViewCell = "ActivityCell"
let kStatisticsTableViewCell = "StatisticsCell"
let kTrendTableViewCell = "trendCell"

let kActivityCollectionViewCell = "ActivityCell"
let kStatisticsCollectionViewCell = "StatisticsCell"

let kDarkBlueColor = UIColor.init(red: 0/255.0, green: 124/255.0, blue: 186/255.0, alpha: 1.0)
let kGreyColor = UIColor.init(red: 140/255.0, green: 149/255.0, blue: 163/255.0, alpha: 1.0)

let kDaySpaces = NSLocalizedStrings("  DAY  ", comment: "")
let kDay = NSLocalizedStrings("Day", comment: "")
let kMonthSpaces = NSLocalizedStrings("  MONTH  ", comment: "")
let kMonth = NSLocalizedStrings("MONTH", comment: "")
let kWeekSpaces = NSLocalizedStrings("  WEEK  ", comment: "")
let kWeek = NSLocalizedStrings("WEEK", comment: "")

let kPullToRefresh = NSLocalizedStrings("Pull to refresh", comment: "")
let kTheStudy = NSLocalizedStrings("The study ", comment: "")
let k100PercentComplete = NSLocalizedStrings(" is 100 percent complete. Thank you for your participation.", comment: "")
let kNoticedMissedActivity = NSLocalizedStrings("We noticed you missed an activity in ", comment: "")
let kEncourageCompleteStudy = NSLocalizedStrings(" today. That’s Ok! We know you’re busy, but we encourage you to complete study activities before they expire.", comment: "")

// MARK:- Eligibility constants

let kMessageForInvalidToken = NSLocalizedStrings("Please enter valid enrollment token", comment: "")

let kMessageValidToken = NSLocalizedStrings("Please enter valid token", comment: "")
let kMessageForMissingStudyId = NSLocalizedStrings("Unable to Enroll, Please try again later.", comment: "")

let kMessageInvalidTokenOrIfStudyDoesNotExist = NSLocalizedStrings("Sorry, this token is invalid. Please enter a valid token to continue.", comment: "")


// MARK:- StudyHomeMessages
let kMessageForStudyUpcomingState = NSLocalizedStrings("This study is an upcoming one and isn't yet open for enrolling participants. Please check back later.", comment: "")
let kMessageForStudyPausedState = NSLocalizedStrings("This study has been temporarily paused. Please check back later.", comment: "")
let kMessageForStudyPausedAfterJoiningState = NSLocalizedStrings("The study has been temporarily paused. You can participate in activities once it is resumed. Please check back later.", comment: "")
let kMessageForStudyClosedState = NSLocalizedStrings("This study has been closed.", comment: "")
let kMessageForStudyWithdrawnState = NSLocalizedStrings("Sorry, this study currently does not allow previously enrolled participants to rejoin the study after they have withdrawn from the study. Please check back later or explore other studies", comment: "")
let kMessageForStudyEnrollingNotAllowed = NSLocalizedStrings("Sorry, enrollment for this study has been closed for now. Please check back later or explore other studies you could join.", comment: "")
let kEnterToken =  NSLocalizedStrings("Enter a token", comment: "")
let kEnterKeyword =  NSLocalizedStrings("Enter keyword(s)", comment: "")


// MARK:- StudyDashboardViewController segues
let unwindToStudyListDashboard = "unwindToStudyListDashboardIdentifier"


// MARK:- FilterListViewController Segue
let filterListSegue = "filterscreenSegue"

// MARK:- Staging User Details

let kStagingUserEmailId = "aqibm@boston-technology.com"
let kIsStagingUser = "StagingUser"
let kFailedToConnectAppleMail = NSLocalizedStrings("Failed to connect to Apple Mail app", comment: "")

// MARK:- Web View

let kUsername = NSLocalizedStrings("Username", comment: "")
let kPassword = NSLocalizedStrings("Password", comment: "")
let kLogIn = NSLocalizedStrings("Log In", comment: "")
