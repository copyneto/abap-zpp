FUNCTION zfmpp_atualizar_user_status.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(IV_OBJECT) TYPE  AUFK-OBJNR
*"     VALUE(IV_STATUS) TYPE  TJ30-ESTAT
*"----------------------------------------------------------------------
  CALL FUNCTION 'STATUS_CHANGE_EXTERN'
    EXPORTING
      objnr               = iv_object
      user_status         = iv_status
    EXCEPTIONS
      object_not_found    = 1
      status_inconsistent = 2
      status_not_allowed  = 3
      OTHERS              = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFUNCTION.
