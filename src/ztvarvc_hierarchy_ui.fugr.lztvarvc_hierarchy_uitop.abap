FUNCTION-POOL ztvarvc_hierarchy_ui.         "MESSAGE-ID ..

TABLES sscrfields.

DATA selscreen_tvarvc_value TYPE rvari_val_255.

* INCLUDE LZTVARVC_HIERARCHY_UID...          " Local class definition

INCLUDE lztvarvc_hierarchy_uid01. " Generic screen handling
INCLUDE lztvarvc_hierarchy_uid02. " Task-specific screen handling
INCLUDE lztvarvc_hierarchy_uid03. " Application driver
INCLUDE lztvarvc_hierarchy_uid04. " Documentation
INCLUDE lztvarvc_hierarchy_uid05. " Utilities
