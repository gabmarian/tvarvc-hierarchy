interface ZIF_TVARVC_HIER_MANAGER
  public .


  types:
    begin of node_id,
      node_id type ztvarvc_hier-node_id,
    end of node_id .
  types:
    node_ids TYPE SORTED TABLE OF node_id WITH UNIQUE KEY node_id .

  events SAVED
    exporting
      value(NODE_IDS) type NODE_IDS .

  methods GET
    importing
      !NODE_ID type CSEQUENCE optional
      !VARIABLE_TYPE type RSSCR_KIND optional
      !VARIABLE_NAME type CSEQUENCE optional
    preferred parameter NODE_ID
    returning
      value(NODE) type ref to ZIF_TVARVC_HIER_NODE .
  methods GET_ROOT
    returning
      value(ROOT) type ref to ZIF_TVARVC_HIER_NODE .
  methods GET_STATUS
    importing
      !NODE type ref to ZIF_TVARVC_HIER_NODE
    returning
      value(STATUS) type ZIF_TVARVC_HIER_NODE=>STATUS
    raising
      ZCX_TVARVC_NOT_EXISTS .
  methods ON_CREATE
    for event CREATED of ZIF_TVARVC_HIER_NODE
    importing
      !SENDER .
  methods ON_CHANGE
    for event CHANGED of ZIF_TVARVC_HIER_NODE
    importing
      !SENDER .
  methods ON_DELETE
    for event DELETED of ZIF_TVARVC_HIER_NODE
    importing
      !SENDER .
  methods HAS_PENDING_CHANGES
    returning
      value(VAL) type ABAP_BOOL .
  methods SAVE
    raising
      ZCX_TVARVC_OPERATION_FAILURE .
endinterface.
