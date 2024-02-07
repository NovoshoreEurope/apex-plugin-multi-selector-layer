PROCEDURE render_plugin (
    p_item   in            apex_plugin.t_item,
    p_plugin in            apex_plugin.t_plugin,
    p_param  in            apex_plugin.t_item_render_param,
    p_result in out nocopy apex_plugin.t_item_render_result )
AS
    --custom plugin attributes
    l_result                                apex_plugin.t_page_item_render_result;
    l_item_name                             VARCHAR2(1000) := apex_plugin.get_input_name_for_page_item(false);
    l_json_clob                             CLOB := p_param.value;
    --
    attr_label_name                         p_item.attribute_02%TYPE := p_item.attribute_02;
    attr_label_color                        p_item.attribute_02%TYPE := p_item.attribute_04;
    attr_sql_query                          p_item.attribute_03%TYPE := p_item.attribute_03;
    -- Define variables para almacenar los resultados
    v_identificador                         VARCHAR2(100);
    v_valor                                 VARCHAR2(200);
    v_descripcion                           VARCHAR2(300);
    v_split_values                          apex_t_varchar2;
    v_checkbox_checked                      VARCHAR2(1); -- You can limit it to 'Y' or 'N'
    -- Define un tipo de referencia a cursor
    TYPE ref_cur IS REF CURSOR;
    -- Declara un cursor dinámico
    c ref_cur;
    --
    l_html                                  VARCHAR2(4000);
    l_clob_to_varchar2                      VARCHAR2(4000);         -- Para almacenar una porción del CLOB.
    l_escaped_html_value                    VARCHAR2(4000);        -- Para almacenar el valor de CLOB escapado para HTML.
    --
BEGIN
    --debug
    if apex_application.g_debug then
      apex_plugin_util.debug_page_item(p_plugin, p_item, p_param.value, p_param.is_readonly, p_param.is_printer_friendly);
    end if;
    --
    l_html := '<button class="t-Button t-Button--icon t-Button--large t-Button--primary t-Button--link t-Button--iconRight t-Button--gapTop lto' || p_item.id || '_0" onclick="void(0);" type="button" id="b-data-multiselect-info">
                <span class="t-Icon t-Icon--left fa fa-angle-down" aria-hidden="true"></span>';
    if attr_label_color is null then
        l_html := l_html || '<span class="t-Button-label">' || attr_label_name || '</span>';
        l_html := l_html || '<span class="t-Icon t-Icon--right fa fa-angle-down" aria-hidden="true"></span></button>';
    else
        l_html := l_html || '<span class="t-Button-label" style="color:' || attr_label_color || '">' || attr_label_name || '</span>';
        l_html := l_html || '<span class="t-Icon t-Icon--right fa fa-angle-down" style="color:' || attr_label_color || '" aria-hidden="true"></span></button>';
    end if;
    --
    l_html :=  l_html || '<div id="data-multiselect-info" class="checkbox-layer"><ul>';
    -- Abre el cursor dinámico con la consulta SQL
    OPEN c FOR attr_sql_query;
    -- Bucle para leer todos los registros del cursor
    LOOP
        -- Obtiene el siguiente registro del cursor
        FETCH c INTO v_identificador, v_valor, v_descripcion;
            -- Sale del bucle si no hay más registros
            EXIT WHEN c%NOTFOUND;
            -- Initialize a variable to track if the checkbox should be checked
            v_checkbox_checked := 'N';
            -- Procesar el JSON para extraer los objetos
            FOR r IN (SELECT j.value FROM json_table(l_json_clob, '$[*]' COLUMNS ( value VARCHAR2(4000) PATH '$' )) j ) LOOP
                IF v_valor = r.value THEN
                    v_checkbox_checked := 'Y';
                    EXIT; -- No need to continue checking if found
                END IF;
            END LOOP;
            --
            l_html :=  l_html || '<li class="no-sign">';
            l_html :=  l_html || '<label>';
            l_html := l_html || '<input name="' || v_identificador || '_li" type="checkbox" value="' || v_valor || '"';
            -- If v_checkbox_checked is 'Y', add the "checked" attribute
            IF v_checkbox_checked = 'Y' THEN
                l_html := l_html || ' checked="checked"';
            END IF;
            l_html := l_html || '>';
            l_html := l_html || '&nbsp;&nbsp;' || v_valor;
            l_html :=  l_html || '</label>';
            l_html :=  l_html || '<button class="uxxi-t-form-help-button js-itemHelp" tabindex="-1" type="button" title="' || v_descripcion || '" aria-label="' || v_descripcion || '"><span class="a-Icon fa fa-info-circle-o" aria-hidden="true" style="color:darkblue; padding-top: 3px;"></span></button>';
            l_html :=  l_html || '</li>';
    END LOOP;
    --
    APEX_DEBUG.LOG_LONG_MESSAGE(p_message => '[DEBUG-INFO] - l_json_clob: '||l_json_clob, p_level => 4);
    -- Convertir CLOB a VARCHAR2 (Asegúrate de que el tamaño del CLOB es manejable)
    l_clob_to_varchar2 := DBMS_LOB.SUBSTR(l_json_clob, 4000, 1); -- Obtiene los primeros 4000 caracteres

    -- Escapar el contenido para HTML
    l_escaped_html_value := apex_escape.html(l_clob_to_varchar2);
    l_html :=  l_html || '</ul><input id="' || l_item_name || '" name="' || l_item_name || '" value="'||l_escaped_html_value||'" type="hidden"></div>';
    -- Cierra el cursor
    CLOSE c;
    --
    htp.p(l_html);
    --
    apex_javascript.add_onload_code(p_code => 'multiSelectWindow._initialize("'||l_item_name||'", "'||l_escaped_html_value||'");');
    --
end render_plugin;