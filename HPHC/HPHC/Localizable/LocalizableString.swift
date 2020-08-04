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

enum LocalizableString: String {

    // MARK: - Global
    case connectionError = "Connection error"
    case connectionProblem = "There was a problem, please try again."
    case ok = "Ok"

    // MARK: - Resources
    case resourceNotAvailable = "This resource is currently unavailable."
    case aboutStudy = "About the Study"
    case leaveSubtitle = "This will also delete your app account."

    // MARK: - Activities

    // MARK: - LAR Consent
    case consentMyselfChoice = "I am signing the consent form on behalf of myself."
    case consentOtherChoice = """
    I am signing the consent form or on behalf of the patient / participant
    in the capacity of a legally authorized representative.
    """
    case consentLARTitle = "The next few steps will capture your informed consent for participation in this study."
    case consentOptionQuestion = "Please select the appropriate option below"
    case consentLARParticipantSectionTitle = "Please specify your relationship to the participant"
    case consentLARParticipantNameDesc = "Please enter the participant's first and last name below"
    case consentLARParticipantFirstName = "Participant's First Name           "
    case consentLARParticipantLastName = "Participant's Last Name"
    
    case consentLARParticipantFirstName2 = "Participant first name:"
    case consentLARParticipantLastName2 = "Participant last name:"
    case consentLARParticipantSignature = "Signature"
    case consentLARParticipantDate = "Date"
    case consentLARFirstName = "First name"
    case consentLARLastName = "Last name"
    case consentLARParticipantRelationship = "Relationship to participant"
    case consentLARPDFTitle = "Consent by a Legally Authorized Representative"
    case consentLARPDFBody = "I am signing the consent document on behalf of the participant, as a legally-authorized representative of the participant."
    

    var localizedString: String { return NSLocalizedString(rawValue, comment: "") }
}
