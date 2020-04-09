interface ZIF_TVARVC_VARIABLE_COLLECTION
  public .


  types:
    BEGIN OF tvarvc_key,
           name TYPE tvarvc-name,
           type TYPE tvarvc-type,
           numb TYPE tvarvc-numb,
         END OF tvarvc_key .
  types:
    tvarvc_keys TYPE SORTED TABLE OF tvarvc_key WITH UNIQUE DEFAULT KEY .

  events SAVED
    exporting
      value(KEYS) type TVARVC_KEYS .

  methods GET_PARAMETER
    importing
      !NAME type TVARVC-NAME
    returning
      value(VALUE) type RVARI_VAL_255 .
  methods GET_SELECT_OPTION
    importing
      !NAME type TVARVC-NAME
    returning
      value(VALUES) type ZCL_TVARVC=>GENERIC_RANGE .
  methods SET_PARAMETER
    importing
      !NAME type TVARVC-NAME
      !VALUE type RVARI_VAL_255 .
  methods SET_SELECT_OPTION
    importing
      !NAME type TVARVC-NAME
      !VALUES type ZCL_TVARVC=>GENERIC_RANGE .
  methods HAS_PENDING_CHANGES
    returning
      value(VAL) type ABAP_BOOL .
  methods SAVE
    raising
      ZCX_TVARVC_OPERATION_FAILURE .

endinterface.
