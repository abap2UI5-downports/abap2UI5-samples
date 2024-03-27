CLASS z2ui5_cl_demo_app_132 DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_serializable_object.
    INTERFACES z2ui5_if_app.

    DATA mv_view_display TYPE abap_bool.
    DATA mo_parent_view  TYPE REF TO z2ui5_cl_xml_view.

    DATA mv_perc         TYPE string.
    DATA mt_table        TYPE REF TO data.
    DATA mt_table_tmp    TYPE REF TO data.
    DATA ms_table_row    TYPE REF TO data.
    DATA mt_table_del    TYPE REF TO data.

    METHODS set_app_data
      IMPORTING !data TYPE string.

  PROTECTED SECTION.
    DATA client            TYPE REF TO z2ui5_if_client.
    DATA check_initialized TYPE abap_bool.

    METHODS on_init.
    METHODS on_event.

    METHODS Render_main.

  PRIVATE SECTION.
    METHODS get_data.

    METHODS get_comp
      RETURNING VALUE(result) TYPE abap_component_tab.

ENDCLASS.

CLASS z2ui5_cl_demo_app_132 IMPLEMENTATION.

  METHOD on_event.
    CASE client->get( )-event.

      WHEN 'BACK'.

        client->nav_app_leave( client->get_app( client->get( )-s_draft-id_prev_app_stack ) ).

    ENDCASE.
  ENDMETHOD.

  METHOD on_init.
    get_Data( ).
    Render_main( ).
  ENDMETHOD.

  METHOD render_main.
      DATA page TYPE REF TO z2ui5_cl_xml_view.
    DATA layout TYPE REF TO z2ui5_cl_xml_view.
    IF mo_parent_view IS INITIAL.

      
      page = z2ui5_cl_xml_view=>factory( ).

    ELSE.

      page = mo_parent_view->get( `Page` ).

    ENDIF.

    
    layout = page->vertical_layout( class = `sapUiContentPadding`
                                          width = `100%` ).
    layout->label( 'ProgressIndicator'
        )->progress_indicator( percentvalue = mv_perc
                               displayvalue = '0,44GB of 32GB used'
                               showvalue    = abap_true
                               state        = 'Success' ).

    IF mo_parent_view IS INITIAL.

      client->view_display( page->get_root( )->xml_get( ) ).

    ELSE.

      mv_view_display = abap_true.

    ENDIF.
  ENDMETHOD.

  METHOD z2ui5_if_app~main.
    me->client = client.

    IF check_initialized = abap_false.
      check_initialized = abap_true.

      on_init( ).

    ENDIF.

    on_event( ).
  ENDMETHOD.

  METHOD set_app_data.
    mv_perc = data.
  ENDMETHOD.

  METHOD get_data.
    FIELD-SYMBOLS <table>     TYPE STANDARD TABLE.
    FIELD-SYMBOLS <table_tmp> TYPE STANDARD TABLE.

    DATA t_comp TYPE abap_component_tab.
        DATA new_struct_desc TYPE REF TO cl_abap_structdescr.
        DATA new_table_desc TYPE REF TO cl_abap_tabledescr.
    t_comp = get_comp( ).

    TRY.

        
        new_struct_desc = cl_abap_structdescr=>create( t_comp ).

        
        new_table_desc = cl_abap_tabledescr=>create( p_line_type  = new_struct_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std ).

        CREATE DATA mt_table     TYPE HANDLE new_table_desc.
        CREATE DATA mt_table_del TYPE HANDLE new_table_desc.
        CREATE DATA mt_table_tmp TYPE HANDLE new_table_desc.
        CREATE DATA ms_table_row TYPE HANDLE new_struct_desc.

        ASSIGN mt_table->* TO <table>.

        SELECT * FROM Z2UI5_T_UTIL_01
          INTO CORRESPONDING FIELDS OF TABLE <table>
          UP TO '100' ROWS.

      CATCH cx_root.

    ENDTRY.

    ASSIGN mt_table_tmp->* TO <table_tmp>.

    <table_tmp> = <table>.
  ENDMETHOD.

  METHOD get_comp.
        DATA index TYPE int4.
            DATA typedesc TYPE REF TO cl_abap_typedescr.
            DATA temp1 TYPE REF TO cl_abap_structdescr.
            DATA structdesc LIKE temp1.
            DATA comp TYPE abap_component_tab.
            DATA com LIKE LINE OF comp.
            DATA root TYPE REF TO cx_root.
        DATA temp2 TYPE cl_abap_structdescr=>component_table.
        DATA temp3 LIKE LINE OF temp2.
        DATA temp4 TYPE REF TO cl_abap_datadescr.
        DATA component LIKE temp2.
    TRY.

        

        TRY.

            
            cl_abap_typedescr=>describe_by_name( EXPORTING  p_name         = 'Z2UI5_T_UTIL_01'
                                                 RECEIVING  p_descr_ref    = typedesc
                                                 EXCEPTIONS type_not_found = 1
                                                            OTHERS         = 2 ).

            
            temp1 ?= typedesc.
            
            structdesc = temp1.

            
            comp = structdesc->get_components( ).

            
            LOOP AT comp INTO com.

              IF com-as_include = abap_false.

                APPEND com TO result.

              ENDIF.

            ENDLOOP.

            
          CATCH cx_root INTO root. " TODO: variable is assigned but never used (ABAP cleaner)

        ENDTRY.

        
        CLEAR temp2.
        
        temp3-name = 'ROW_ID'.
        
        temp4 ?= cl_abap_datadescr=>describe_by_data( index ).
        temp3-type = temp4.
        INSERT temp3 INTO TABLE temp2.
        
        component = temp2.

        APPEND LINES OF component TO result.

      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
