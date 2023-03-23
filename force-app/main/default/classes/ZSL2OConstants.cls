/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ZSL2OConstants
* @description    This is the Common class contains the constants that can be used accross the L2O Pod.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Zscaler
* @modifiedBy     
* @maintainedBy   Zscaler
* @version        1.0
* @created        2022-11-23
* @modified       
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.1            Digvijay Singh
* YYYY-MM-DD      Explanation of the change.  Multiple lines can be used to explain the change, but
*                 each line should be indented till left aligned with the previous description text.
* 2022-05-23      IBA-4849 Digvijay - Creation of the class for having a common class to maintain all
                  the constants that can be used by any classes across L2O Pod.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
**/
public class ZSL2OConstants {
    
    public static final String STATUS_ATTENDED = 'Attended';

    public static final String ACCOUNT_TYPE_PROSPECT = 'Prospect';

    public static final String FISCAL_YEAR_FY_22 = 'FY 22';
    
    public static final String CXO_SPEAKER_RECORD_TYPE_NAME = 'CXO Speaker';

    public static final String SPEAKER_RECORD_TYPE_NAME = 'Speaker';

    public static final String PERMISSION_SET_NAME_SPEAKER_BUREAU_COORDINATOR = 'Speaker Bureau Coordinator';

    public static final String SPEAKERS_SPEAKER_RATING_NOT_ALLOWED_ERROR_MESSAGE = System.Label.Speakers_Speaker_Rating_Not_Allowed_Error_Message;
    
    public static final String SPEAKERS_FILL_MANDATORY_FIELDS_WHEN_RATING_THE_SPEAKER_ERROR_MESSAGE = System.Label.Speakers_Fill_Mandatory_Fields_When_Rating_The_Speaker_Error_Message;
}