
* Empty screen for binding the hierarchy tree
SELECTION-SCREEN BEGIN OF SCREEN 1100.
SELECTION-SCREEN END OF SCREEN 1100.

* Node maintenenace
SELECTION-SCREEN BEGIN OF SCREEN 1200 AS WINDOW TITLE TEXT-w01.

SELECTION-SCREEN BEGIN OF BLOCK node_attributes.
PARAMETERS name TYPE ztvarvc_hier-node_name LOWER CASE OBLIGATORY.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK attr WITH FRAME TITLE TEXT-001.
PARAMETERS descr TYPE ztvarvc_hier-description  LOWER CASE.
PARAMETERS appcomp TYPE ztvarvc_hier-appl_component.
SELECTION-SCREEN END OF BLOCK attr.
SELECTION-SCREEN BEGIN OF BLOCK vari WITH FRAME TITLE TEXT-002.
PARAMETERS xpar RADIOBUTTON GROUP vari MODIF ID var DEFAULT 'X'.
PARAMETERS xsel RADIOBUTTON GROUP vari MODIF ID var.
PARAMETERS varname TYPE ztvarvc_hier-tvarv_name MODIF ID var.
SELECTION-SCREEN BEGIN OF BLOCK variref WITH FRAME TITLE TEXT-004.
PARAMETERS tabname TYPE ztvarvc_hier-tabname    MODIF ID var.
PARAMETERS fldname TYPE ztvarvc_hier-fieldname  MODIF ID var.
SELECTION-SCREEN END OF BLOCK variref.
SELECTION-SCREEN END OF BLOCK vari.
SELECTION-SCREEN END OF BLOCK node_attributes.

SELECTION-SCREEN BEGIN OF BLOCK modif WITH FRAME TITLE TEXT-003.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) FOR FIELD cron.
PARAMETERS cron TYPE ztvarvc_hier-created_on MODIF ID his.
SELECTION-SCREEN COMMENT 55(31) FOR FIELD chon.
PARAMETERS chon TYPE ztvarvc_hier-changed_on MODIF ID his.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(31) FOR FIELD crby.
PARAMETERS crby TYPE ztvarvc_hier-created_by MODIF ID his.
SELECTION-SCREEN COMMENT 55(31) FOR FIELD chby.
PARAMETERS chby TYPE ztvarvc_hier-changed_by MODIF ID his.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK modif.

SELECTION-SCREEN END OF SCREEN 1200.

* Node creation
SELECTION-SCREEN BEGIN OF SCREEN 1300 AS WINDOW.
SELECTION-SCREEN INCLUDE BLOCKS node_attributes.
SELECTION-SCREEN END OF SCREEN 1300.

* Parameter maintenance
SELECTION-SCREEN BEGIN OF SCREEN 1400 AS WINDOW.
PARAMETERS parname TYPE ztvarvc_hier-tvarv_name.
PARAMETERS parval  TYPE rvari_val_255.
SELECTION-SCREEN END OF SCREEN 1400.

* Select-option manintenance
SELECTION-SCREEN BEGIN OF SCREEN 1500 AS WINDOW.
PARAMETERS selname TYPE ztvarvc_hier-tvarv_name.
SELECT-OPTIONS selval FOR selscreen_tvarvc_value.
SELECTION-SCREEN END OF SCREEN 1500.

* Empty screen for binding the documentation editor
SELECTION-SCREEN BEGIN OF SCREEN 1600 AS WINDOW.
SELECTION-SCREEN END OF SCREEN 1600.

* Search
SELECTION-SCREEN BEGIN OF SCREEN 1700 AS WINDOW.
SELECTION-SCREEN INCLUDE PARAMETERS xpar.
SELECTION-SCREEN INCLUDE PARAMETERS xsel.
SELECTION-SCREEN INCLUDE PARAMETERS varname.
SELECTION-SCREEN END OF SCREEN 1700.
