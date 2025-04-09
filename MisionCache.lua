-- MisionCache Addon
-- Captura información de misiones en TurtleWoW (Vanilla)
-- SavedVariables: MisionCacheDB, MisionCacheConfig
-- Versión: 1.2
-- Creado por Darkneo

-- Variable global para guardar las misiones
MisionCacheDB = MisionCacheDB or {}
MisionCacheConfig = MisionCacheConfig or { 
    minimapPos = 45, -- Posición del icono en el minimapa
    debug = false    -- Modo debug desactivado por defecto
}

-- Crear el frame principal
local MisionFrame = CreateFrame("Frame")

-- Función para debug - usamos AddMessage en lugar de print (que no existe en Vanilla)
local function Debug(msg)
    if MisionCacheConfig.debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[MisionCache Debug]|r " .. tostring(msg))
    end
end

-- Frame para mostrar y seleccionar el link de Discord
local function CrearFrameDiscord()
    -- Verificar si ya existe el frame
    if MisionFrame.discordFrame then
        MisionFrame.discordFrame:Show()
        return
    end
    
    -- Crear el frame
    local frame = CreateFrame("Frame", "MisionCacheDiscordFrame", UIParent)
    frame:SetWidth(350)
    frame:SetHeight(130)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    -- Usar una strata más alta para superponerlo a otros elementos
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() this:StartMoving() end)
    frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    
    -- Fondo del frame con una textura totalmente negra
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    -- Ajustar la transparencia del fondo - totalmente negro y opaco
    frame:SetBackdropColor(0, 0, 0, 1)
    
    -- Añadir un overlay sombreado para asegurar mayor contraste
    local overlayBg = frame:CreateTexture(nil, "BACKGROUND")
    overlayBg:SetAllPoints()
    overlayBg:SetTexture(0, 0, 0, 0.8)
    
    -- Título
    local titulo = frame:CreateFontString(nil, "ARTWORK")
    titulo:SetFont("Fonts\\FRIZQT__.TTF", 14)
    titulo:SetTextColor(1, 0.8, 0)
    titulo:SetPoint("TOP", frame, "TOP", 0, -15)
    titulo:SetText("Unirse al Discord")
    
    -- Texto principal
    local textoPrincipal = frame:CreateFontString(nil, "ARTWORK")
    textoPrincipal:SetFont("Fonts\\FRIZQT__.TTF", 12)
    textoPrincipal:SetTextColor(1, 1, 1)
    textoPrincipal:SetPoint("TOP", titulo, "BOTTOM", 0, -15)
    textoPrincipal:SetWidth(300)
    textoPrincipal:SetJustifyH("CENTER")
    textoPrincipal:SetText("Copia este enlace y pégalo en tu navegador:")
    
    -- Campo de texto con el enlace
    local editBox = CreateFrame("EditBox", "MisionCacheDiscordLink", frame)
    editBox:SetFont("Fonts\\FRIZQT__.TTF", 12)
    editBox:SetWidth(290)
    editBox:SetHeight(20)
    editBox:SetPoint("TOP", textoPrincipal, "BOTTOM", 0, -10)
    editBox:SetText("https://discord.com/invite/jHPsF2dt9y")
    editBox:SetAutoFocus(true)
    editBox:HighlightText()
    
    -- Añadir bordes y fondo al EditBox - más claro para contrastar
    editBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    editBox:SetBackdropColor(0.1, 0.1, 0.1, 1)
    editBox:SetBackdropBorderColor(0.8, 0.8, 0.8)
    
    -- Botón de cerrar
    local botonCerrar = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    botonCerrar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    
    -- Botón de aceptar
    local botonAceptar = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    botonAceptar:SetWidth(100)
    botonAceptar:SetHeight(25)
    botonAceptar:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
    botonAceptar:SetText("Aceptar")
    botonAceptar:SetScript("OnClick", function()
        this:GetParent():Hide()
    end)
    
    -- Guardar referencia
    MisionFrame.discordFrame = frame
end

-- Crear frame de opciones
local function CrearMenuOpciones()
    -- Si ya existe, solo mostrarlo
    if MisionFrame.opcionesFrame then
        MisionFrame.opcionesFrame:Show()
        return
    end
    
    -- Crear el frame principal
    local frame = CreateFrame("Frame", "MisionCacheOpcionesFrame", UIParent)
    frame:SetWidth(400)
    frame:SetHeight(350)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function() this:StartMoving() end)
    frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    
    -- Fondo del frame con una textura más atractiva
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    
    -- Ajustar la transparencia del fondo - usar color oscuro para mayor visibilidad
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    
    -- Imagen de libro como decoración
    local libroImagen = frame:CreateTexture(nil, "ARTWORK")
    libroImagen:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon")
    libroImagen:SetWidth(64)
    libroImagen:SetHeight(64)
    libroImagen:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -10)
    
    -- Título
    local titulo = frame:CreateFontString(nil, "ARTWORK")
    titulo:SetFont("Fonts\\FRIZQT__.TTF", 18)
    titulo:SetTextColor(1, 0.8, 0)
    
    -- POSICIONES DEL TÍTULO - Descomenta la que prefieras
    
    -- Posición original (centrado arriba)
    titulo:SetPoint("TOP", frame, "TOP", 0, -15)
    
    -- Opción 1: Título a la izquierda arriba
    -- titulo:SetPoint("TOPLEFT", frame, "TOPLEFT", 80, -15)
    
    -- Opción 2: Título a la derecha arriba
    -- titulo:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -80, -15)
    
    -- Opción 3: Título en el centro del frame
    -- titulo:SetPoint("CENTER", frame, "CENTER", 0, 120)
    
    -- Texto principal
    titulo:SetText("|cFFFFCC00MisionCache|r")
    
    -- Sufijo pequeño junto al título (en la misma línea)
    local sufijo = frame:CreateFontString(nil, "ARTWORK")
    sufijo:SetFont("Fonts\\FRIZQT__.TTF", 14) -- Tamaño más pequeño
    sufijo:SetTextColor(0.6, 0.2, 0.8) -- Color morado
    sufijo:SetPoint("LEFT", titulo, "RIGHT", 0, -1) -- Ajustar para alinear visualmente
    sufijo:SetText("-mDarkneo")
    
    -- Línea separadora
    local linea = frame:CreateTexture(nil, "ARTWORK")
    linea:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Divider")
    linea:SetWidth(350)
    linea:SetHeight(16)
    
    -- POSICIONES DE LA LÍNEA - Descomenta la que prefieras según la posición del título
    
    -- Posición original (debajo del título)
    linea:SetPoint("TOP", titulo, "BOTTOM", 60, -3)
    
    -- Descripción
    local descripcion = frame:CreateFontString(nil, "ARTWORK")
    descripcion:SetFont("Fonts\\FRIZQT__.TTF", 12)
    descripcion:SetTextColor(1, 1, 1)
    descripcion:SetPoint("TOPLEFT", frame, "TOPLEFT", 90, -50)
    descripcion:SetWidth(290)
    descripcion:SetJustifyH("LEFT")
    descripcion:SetText("Addon creado especialmente para TurtleWoW para capturar misiones custom y otras misiones con el objetivo de mejorar voiceover.")
    
    -- Discord
    local discord = frame:CreateFontString(nil, "ARTWORK")
    discord:SetFont("Fonts\\FRIZQT__.TTF", 12)
    discord:SetTextColor(0.5, 0.5, 1)
    discord:SetPoint("TOPLEFT", descripcion, "BOTTOMLEFT", 0, -10)
    discord:SetWidth(290)
    discord:SetJustifyH("LEFT")
    discord:SetText("Discord: ")
    
    -- Botón de Discord
    local botonDiscord = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    botonDiscord:SetWidth(150)
    botonDiscord:SetHeight(22)
    botonDiscord:SetPoint("LEFT", discord, "LEFT", 55, 0)
    botonDiscord:SetText("Unirse al Discord")
    botonDiscord:SetScript("OnClick", function()
        CrearFrameDiscord()
    end)
    
    -- Subtítulo Misiones
    local subtituloMisiones = frame:CreateFontString(nil, "ARTWORK")
    subtituloMisiones:SetFont("Fonts\\FRIZQT__.TTF", 13)
    subtituloMisiones:SetTextColor(1, 0.8, 0)
    subtituloMisiones:SetPoint("TOPLEFT", discord, "BOTTOMLEFT", 0, -15)
    subtituloMisiones:SetWidth(290)
    subtituloMisiones:SetJustifyH("LEFT")
    subtituloMisiones:SetText("¿Cómo compartir tus capturas?")
    
    -- Instrucciones para compartir archivos en lugar del scroll frame
    local instrucciones = frame:CreateFontString(nil, "ARTWORK")
    instrucciones:SetFont("Fonts\\FRIZQT__.TTF", 12)
    instrucciones:SetTextColor(1, 1, 1)
    instrucciones:SetPoint("TOPLEFT", subtituloMisiones, "BOTTOMLEFT", 0, -10)
    instrucciones:SetWidth(290)
    instrucciones:SetJustifyH("LEFT")
    instrucciones:SetText("1. Captura misiones mientras juegas en TurtleWoW.\n\n2. Busca el archivo '|cFFFFFF00WTF/Account/TU_CUENTA/SavedVariables/MisionCache.lua|r'.\n\n3. Envía este archivo al canal |cFFA335EE#es-MisionCache|r en nuestro Discord.\n\n4. ¡Ayuda a mejorar el proyecto de voiceover para TurtleWoW!")
    
    -- Botón Guardar (real pero invisible)
    local botonGuardar = CreateFrame("Button", nil, frame)
    botonGuardar:SetWidth(250)
    botonGuardar:SetHeight(30)
    botonGuardar:SetPoint("TOPLEFT", instrucciones, "BOTTOMLEFT", 0, -15)
    
    -- Texto del botón (actúa como visual del botón)
    local textoBoton = frame:CreateFontString(nil, "ARTWORK") 
    textoBoton:SetFont("Fonts\\FRIZQT__.TTF", 11)
    textoBoton:SetTextColor(1, 0.82, 0, 1) -- Color dorado
    textoBoton:SetPoint("TOPLEFT", instrucciones, "BOTTOMLEFT", 80, -15)
    textoBoton:SetText("Guardar Capturas Ahora")

    -- Texto adicional de información
    local textoInfo = frame:CreateFontString(nil, "OVERLAY") 
    textoInfo:SetFont("Fonts\\FRIZQT__.TTF", 9)
    textoInfo:SetTextColor(0.7, 0.7, 0.7, 1) -- Color gris claro
    textoInfo:SetPoint("TOP", textoBoton, "BOTTOM", 0, 0)
    textoInfo:SetText("(Esto reiniciará la interfaz)")
    
    -- Icono de libro pequeño a la izquierda del texto (opcional)
    local iconoLibro = frame:CreateTexture(nil, "ARTWORK")
    iconoLibro:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    iconoLibro:SetWidth(16)
    iconoLibro:SetHeight(16)
    iconoLibro:SetPoint("RIGHT", textoBoton, "LEFT", -5, 0)
    
    -- Hacer que el botón invisible cubra tanto el texto como el icono
    botonGuardar:SetPoint("TOPLEFT", iconoLibro, "TOPLEFT", -5, 5)
    botonGuardar:SetPoint("BOTTOMRIGHT", textoBoton, "BOTTOMRIGHT", 5, -5)
    
    -- Configurar el botón para capturar eventos del ratón
    botonGuardar:EnableMouse(true)
    
    -- Efecto al poner el mouse encima
    botonGuardar:SetScript("OnEnter", function()
        -- Hacer el texto más grande
        textoBoton:SetFont("Fonts\\FRIZQT__.TTF", 14) -- Texto más grande
        textoBoton:SetTextColor(1, 1, 0.5, 1) -- Amarillo más brillante
        iconoLibro:SetWidth(20) -- Icono más grande
        iconoLibro:SetHeight(20)
        -- Mostrar tooltip
        GameTooltip:SetOwner(this, "ANCHOR_TOP")
        GameTooltip:AddLine("Guarda todas las capturas y reinicia la interfaz")
        GameTooltip:Show()
    end)

    botonGuardar:SetScript("OnLeave", function()
        -- Restaurar tamaño original
        textoBoton:SetFont("Fonts\\FRIZQT__.TTF", 11)
        textoBoton:SetTextColor(1, 0.82, 0, 1) -- Volver al dorado original
        iconoLibro:SetWidth(16) -- Icono tamaño normal
        iconoLibro:SetHeight(16)
        -- Ocultar tooltip
        GameTooltip:Hide()
    end)

    -- Al hacer clic, reiniciar la interfaz
    botonGuardar:SetScript("OnClick", function()
        ReloadUI()
    end)
    
    -- Contador de misiones actuales
    local contador = 0
    local progressCount = 0
    local completeCount = 0
    local detailCount = 0
    local gossipCount = 0
    local bocadilloCount = 0
    local gritoCount = 0
    
    for id, mision in pairs(MisionCacheDB) do
        if id ~= "AccountName" then -- Ignorar la entrada de AccountName
            if mision.Evento == "detail" then
                contador = contador + 1
                detailCount = detailCount + 1
            elseif mision.Evento == "complete" then
                contador = contador + 1
                completeCount = completeCount + 1
            elseif mision.Evento == "progress" then
                contador = contador + 1
                progressCount = progressCount + 1
            elseif mision.Evento == "gossip" then
                gossipCount = gossipCount + 1
            elseif mision.Evento == "bocadillo" then
                bocadilloCount = bocadilloCount + 1
            elseif mision.Evento == "grito" then
                gritoCount = gritoCount + 1
            end
        end
    end
    
    -- Total de misiones
    local totalMisiones = frame:CreateFontString(nil, "ARTWORK")
    totalMisiones:SetFont("Fonts\\FRIZQT__.TTF", 12)
    totalMisiones:SetTextColor(1, 1, 0)
    totalMisiones:SetPoint("BOTTOM", frame, "BOTTOM", 0, 30)
    totalMisiones:SetText("Total Capturas: " .. (contador + gossipCount + bocadilloCount + gritoCount))
    
    -- Detalles por tipo - Todos en una sola línea
    local detallesMisiones = frame:CreateFontString(nil, "ARTWORK")
    detallesMisiones:SetFont("Fonts\\FRIZQT__.TTF", 11)
    detallesMisiones:SetTextColor(0.8, 0.8, 0.8)
    detallesMisiones:SetPoint("BOTTOM", totalMisiones, "BOTTOM", 0, -15)
    detallesMisiones:SetWidth(350)
    detallesMisiones:SetJustifyH("CENTER")
    detallesMisiones:SetText("Detail: " .. detailCount .. " | Progress: " .. progressCount .. " | Complete: " .. completeCount .. " | Gossip: " .. gossipCount .. " | Bocadillos: " .. bocadilloCount .. " | Gritos: " .. gritoCount)
    
    -- Botón de opciones (engranaje) - Reposicionado y más grande
    local botonOpciones = CreateFrame("Button", nil, frame)
    botonOpciones:SetWidth(32)
    botonOpciones:SetHeight(32)
    botonOpciones:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 20)
    
    -- Crear textura del engranaje con bordes visibles
    local texturaEngranaje = botonOpciones:CreateTexture(nil, "BACKGROUND")
    texturaEngranaje:SetTexture("Interface\\Buttons\\UI-OptionsButton")
    texturaEngranaje:SetAllPoints(botonOpciones)
    
    -- Resaltar al pasar el ratón con un brillo más notorio
    botonOpciones:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
    
    -- Efecto de pulsación
    botonOpciones:SetPushedTexture("Interface\\Buttons\\UI-OptionsButton")
    
    -- Tooltip al pasar el ratón
    botonOpciones:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Opciones Avanzadas")
        GameTooltip:Show()
    end)
    
    botonOpciones:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Función para crear y mostrar el menú de opciones avanzadas
    local function MostrarOpcionesAvanzadas()
        -- Si ya existe el menú, lo mostramos
        if MisionFrame.opcionesAvanzadasFrame then
            MisionFrame.opcionesAvanzadasFrame:Show()
            return
        end
        
        -- Crear frame de opciones avanzadas
        local menuOpciones = CreateFrame("Frame", "MisionCacheOpcionesAvanzadasFrame", UIParent)
        menuOpciones:SetWidth(250)
        menuOpciones:SetHeight(130)
        menuOpciones:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        menuOpciones:SetFrameStrata("DIALOG")
        menuOpciones:EnableMouse(true)
        menuOpciones:SetMovable(true)
        menuOpciones:RegisterForDrag("LeftButton")
        menuOpciones:SetScript("OnDragStart", function() this:StartMoving() end)
        menuOpciones:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
        
        -- Fondo del frame
        menuOpciones:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        
        -- Ajustar la transparencia del fondo - usar color oscuro para mayor visibilidad
        menuOpciones:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        
        -- Título
        local tituloOpciones = menuOpciones:CreateFontString(nil, "ARTWORK")
        tituloOpciones:SetFont("Fonts\\FRIZQT__.TTF", 14)
        tituloOpciones:SetTextColor(1, 0.8, 0)
        tituloOpciones:SetPoint("TOP", menuOpciones, "TOP", 0, -15)
        tituloOpciones:SetText("Opciones Avanzadas")
        
        -- Línea separadora
        local lineaOpciones = menuOpciones:CreateTexture(nil, "ARTWORK")
        lineaOpciones:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Divider")
        lineaOpciones:SetWidth(200)
        lineaOpciones:SetHeight(16)
        lineaOpciones:SetPoint("TOP", tituloOpciones, "BOTTOM", 0, 0)
        
        -- Advertencia
        local advertencia = menuOpciones:CreateFontString(nil, "ARTWORK")
        advertencia:SetFont("Fonts\\FRIZQT__.TTF", 10)
        advertencia:SetTextColor(1, 0.3, 0.3)
        advertencia:SetPoint("TOP", lineaOpciones, "BOTTOM", 0, -10)
        advertencia:SetWidth(220)
        advertencia:SetJustifyH("CENTER")
        advertencia:SetText("¡ATENCIÓN! Esta acción no se puede deshacer.")
        
        -- Botón para limpiar caché
        local botonLimpiar = CreateFrame("Button", nil, menuOpciones, "UIPanelButtonTemplate")
        botonLimpiar:SetWidth(160)
        botonLimpiar:SetHeight(25)
        botonLimpiar:SetPoint("TOP", advertencia, "BOTTOM", 0, -15)
        botonLimpiar:SetText("Limpiar base de datos")
        botonLimpiar:SetScript("OnClick", function()
            MisionCacheDB = {}
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[MisionCache]|r Base de datos limpiada.")
            this:GetParent():Hide()
            MisionFrame.opcionesFrame:Hide()
            -- Volver a mostrar con la lista vacía
            CrearMenuOpciones()
        end)
        
        -- Botón de cerrar
        local botonCerrarOpciones = CreateFrame("Button", nil, menuOpciones, "UIPanelCloseButton")
        botonCerrarOpciones:SetPoint("TOPRIGHT", menuOpciones, "TOPRIGHT", -5, -5)
        
        -- Guardar referencia
        MisionFrame.opcionesAvanzadasFrame = menuOpciones
    end
    
    -- Acción al hacer clic en el botón de opciones
    botonOpciones:SetScript("OnClick", function()
        MostrarOpcionesAvanzadas()
    end)
    
    -- Botón de cerrar
    local botonCerrar = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    botonCerrar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    
    -- Guardar una referencia al frame
    MisionFrame.opcionesFrame = frame
end

-- Crear icono del minimapa
local function CrearIconoMinimapa()
    -- Crear el botón
    local minimapButton = CreateFrame("Button", "MisionCacheMinimapButton", Minimap)
    minimapButton:SetWidth(31)
    minimapButton:SetHeight(31)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)
    minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    -- Establecer textura (icono)
    local icono = minimapButton:CreateTexture(nil, "BACKGROUND")
    icono:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icono:SetWidth(20)
    icono:SetHeight(20)
    icono:SetPoint("CENTER", 0, 0)
    minimapButton.icono = icono
    
    -- Fondo del botón
    local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    overlay:SetWidth(53)
    overlay:SetHeight(53)
    overlay:SetPoint("TOPLEFT", 0, 0)
    
    -- Configurar posición
    minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * math.cos(MisionCacheConfig.minimapPos)), (80 * math.sin(MisionCacheConfig.minimapPos)) - 52)
    
    -- Los frames en Vanilla no se pueden mover directamente, usamos el enfoque clásico
    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:SetScript("OnDragStart", function()
        this:LockHighlight()
        this.isDragging = true
    end)
    
    minimapButton:SetScript("OnDragStop", function()
        this:UnlockHighlight()
        this.isDragging = false
    end)
    
    -- Actualizar posición durante el movimiento
    minimapButton:SetScript("OnUpdate", function()
        if this.isDragging then
            local xpos, ypos = GetCursorPosition()
            local xmin, ymin = Minimap:GetCenter()
            local scale = Minimap:GetEffectiveScale()
            
            xpos = xpos / scale
            ypos = ypos / scale
            
            xpos = xpos - xmin
            ypos = ypos - ymin
            
            local angle = math.deg(math.atan2(ypos, xpos))
            MisionCacheConfig.minimapPos = angle
            
            -- Actualizar posición
            this:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (80 * math.cos(MisionCacheConfig.minimapPos)), (80 * math.sin(MisionCacheConfig.minimapPos)) - 52)
        end
    end)
    
    -- Tooltip al pasar el ratón
    minimapButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:AddLine("MisionCache")
        GameTooltip:AddLine("Clic izquierdo: Mostrar misiones")
        GameTooltip:AddLine("Clic derecho: Opciones")
        GameTooltip:Show()
    end)
    
    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Funcionalidad al hacer clic
    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimapButton:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            ImprimirMisiones()
        elseif arg1 == "RightButton" then
            -- Mostrar frame de opciones
            CrearMenuOpciones()
        end
    end)
    
    -- Guardar una referencia al botón
    MisionFrame.minimapButton = minimapButton
end

-- Registrar eventos relevantes
MisionFrame:RegisterEvent("QUEST_GREETING")
MisionFrame:RegisterEvent("QUEST_DETAIL")
MisionFrame:RegisterEvent("QUEST_PROGRESS")
MisionFrame:RegisterEvent("QUEST_COMPLETE")
MisionFrame:RegisterEvent("GOSSIP_SHOW")
MisionFrame:RegisterEvent("ADDON_LOADED")
MisionFrame:RegisterEvent("CHAT_MSG_MONSTER_SAY") -- Para bocadillos normales de NPC
MisionFrame:RegisterEvent("CHAT_MSG_MONSTER_YELL") -- Para gritos de NPC

-- Función para generar un ID único basado en el texto
local function GenerarHashID(texto)
    -- Verificar que tenemos texto válido para procesar
    if not texto or texto == "" then
        return "sin-texto"
    end
    
    -- Extraer los primeros caracteres si el texto es largo
    local textoCorto = texto
    if string.len(texto) > 20 then
        textoCorto = string.sub(texto, 1, 20)
    end
    
    -- Generar un ID simple - primeros 3 caracteres + longitud + último carácter
    local prefijo = string.sub(textoCorto, 1, 3)
    local longitud = tostring(string.len(texto))
    local sufijo = string.sub(texto, -1)
    
    -- Convertir todo a valores ASCII para evitar caracteres raros
    local id = ""
    for i = 1, string.len(prefijo) do
        id = id .. tostring(string.byte(string.sub(prefijo, i, i)))
    end
    
    -- Añadir longitud y sufijo
    id = id .. longitud .. string.byte(sufijo)
    
    -- Verificación final
    if id == "0" or id == "" then
        id = "ID" .. string.len(texto)
    end
    
    return id
end

-- Función para guardar datos en el formato correcto
local function GuardarDatos(misionID, evento, titulo, texto, objetivos, npcNombre, npcID)
    -- Verificar que tenemos IDs válidos
    if npcID == "0" or npcID == "" then
        npcID = GenerarHashID(npcNombre .. "npc")
    end
    
    -- Primero vaciar cualquier valor previo
    MisionCacheDB[misionID] = nil
    
    -- Crear cada campo en el orden exacto deseado
    MisionCacheDB[misionID] = {}
    MisionCacheDB[misionID].Evento = evento
    MisionCacheDB[misionID].Titulo = titulo or ""
    MisionCacheDB[misionID].Texto = texto or ""
    MisionCacheDB[misionID].NPC = {}
    MisionCacheDB[misionID].NPC.ID = npcID
    MisionCacheDB[misionID].NPC.Nombre = npcNombre or "Desconocido"
    MisionCacheDB[misionID].Objetivos = objetivos or ""
end

-- Función para guardar la misión en la caché
local function GuardarMision(evento, titulo, texto, objetivos)
    -- Obtener información del NPC
    local npcNombre = UnitName("target") or "Desconocido"
    local npcID = GenerarHashID(npcNombre)
    
    -- Verificar que tenemos un ID válido
    if npcID == "0" or npcID == "" then
        npcID = GenerarHashID(npcNombre .. time())
    end
    
    -- Generar ID único basado en el texto de la misión
    local textoParaHash = (titulo or "") .. (texto or "")
    local misionID = GenerarHashID(textoParaHash)
    
    -- Verificar que el ID es válido
    if misionID == "0" or misionID == "" then
        misionID = GenerarHashID(textoParaHash .. time())
    end
    
    -- Verificar si ya existe la misión
    if MisionCacheDB[misionID] then
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[MisionCache]|r Misión ya capturada anteriormente - " .. titulo)
        return misionID
    end
    
    -- Guardar datos con el orden correcto
    GuardarDatos(misionID, evento, titulo, texto, objetivos, npcNombre, npcID)
    
    -- Mostrar mensaje en el chat
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[MisionCache]|r Capturada - " .. titulo)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00ID:|r " .. misionID)
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00NPC:|r " .. npcNombre .. " (ID: " .. npcID .. ")")
    
    return misionID
end

-- Función para manejar los eventos
local function OnEvent()
    -- Inicializar random seed si es necesario
    if not MisionFrame.randomInitialized then
        math.randomseed(time())
        MisionFrame.randomInitialized = true
    end
    
    -- Para el evento ADDON_LOADED
    if event == "ADDON_LOADED" and arg1 == "MisionCache" then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[MisionCache]|r Addon cargado. Capturando automáticamente misiones.")
        
        -- Obtener el nombre de cuenta solo una vez al inicio
        if not MisionCacheDB.AccountName then
            -- Intentar obtener el nombre de cuenta
            local accountName = GetAccountName and GetAccountName() or nil
            
            if not accountName or accountName == "" then
                accountName = GetCVar("accountName") or nil
                
                if not accountName or accountName == "" then
                    local realm = GetRealmName() or "Desconocido"
                    local player = UnitName("player") or "Desconocido"
                    accountName = player .. "-" .. realm
                end
            end
            
            -- Guardar el nombre de cuenta obtenido
            MisionCacheDB.AccountName = accountName
        end
        
        -- Inicializar configuración si no existe
        if MisionCacheConfig.debug == nil then
            MisionCacheConfig.debug = false
        end
        
        if MisionCacheConfig.debug then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[MisionCache]|r Modo de depuración activado.")
        end
        
        math.randomseed(time())
        -- Crear el icono del minimapa
        CrearIconoMinimapa()
        return
    end
    
    if event == "QUEST_GREETING" then
        -- Cuando hablamos con un NPC que ofrece varias misiones
        local npcNombre = UnitName("target") or "Desconocido"
        local npcID = GenerarHashID(npcNombre)
        
        -- Verificar que tenemos un ID válido
        if npcID == "0" or npcID == "" then
            npcID = GenerarHashID(npcNombre .. time())
        end
        
        -- Generar ID único (sin prefijo)
        local greetingID = npcID
        
        -- Obtener misiones disponibles
        local numDisponibles = GetNumAvailableQuests() or 0
        local misionesDisponibles = {}
        if numDisponibles > 0 then
            for i = 1, numDisponibles do
                local titulo = GetAvailableTitle(i)
                if titulo then
                    misionesDisponibles[i] = titulo
                end
            end
        end
        
        -- Obtener misiones activas
        local numActivas = GetNumActiveQuests() or 0
        local misionesActivas = {}
        if numActivas > 0 then
            for i = 1, numActivas do
                local titulo = GetActiveTitle(i)
                if titulo then
                    misionesActivas[i] = titulo
                end
            end
        end
        
        -- Verificar si ya existe
        if MisionCacheDB[greetingID] then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[MisionCache]|r Greeting ya capturado para " .. npcNombre)
            return
        end
        
        -- Guardar datos con formato estandarizado
        GuardarDatos(greetingID, "greeting", npcNombre, "", "", npcNombre, npcID)
        
        -- Guardar listas de misiones
        MisionCacheDB[greetingID].MisionesDisponibles = misionesDisponibles
        MisionCacheDB[greetingID].MisionesActivas = misionesActivas
        
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[MisionCache]|r Greeting capturado de " .. npcNombre)
        
    elseif event == "QUEST_DETAIL" then
        -- Cuando se muestra el detalle de una misión
        local titulo = GetTitleText() or "Sin título"
        local texto = GetQuestText() or ""
        local objetivos = GetObjectiveText() or ""
        
        GuardarMision("detail", titulo, texto, objetivos)
        
    elseif event == "QUEST_PROGRESS" then
        -- Cuando estamos en la ventana de progreso de una misión
        local titulo = GetTitleText() or "Sin título"
        local textoProgreso = QuestProgressText:GetText() or ""
        
        GuardarMision("progress", titulo, textoProgreso, "")
        
    elseif event == "QUEST_COMPLETE" then
        -- Cuando completamos una misión
        local titulo = GetTitleText() or "Sin título"
        local textoRecompensa = GetRewardText() or ""
        
        GuardarMision("complete", titulo, textoRecompensa, "")
        
    elseif event == "GOSSIP_SHOW" then
        -- Cuando hablamos con un NPC (diálogo general)
        local npcNombre = UnitName("target") or "Desconocido"
        local npcID = GenerarHashID(npcNombre)
        
        -- Verificar que tenemos un ID válido
        if npcID == "0" or npcID == "" then
            npcID = GenerarHashID(npcNombre .. time())
        end
        
        -- Capturar el texto de gossip principal
        local textoGossip = ""
        if GossipFrameGreetingPanel and GossipFrameGreetingPanel:IsVisible() then
            textoGossip = GossipGreetingText:GetText() or ""
        elseif GossipFrame and GossipFrame:IsVisible() then
            textoGossip = GossipText:GetText() or ""
        end
        
        -- Guardar opciones de diálogo disponibles
        local numOpciones = GossipFrame.buttonIndex or 0
        local opciones = {}
        
        for i = 1, numOpciones do
            local button = getglobal("GossipTitleButton" .. i)
            if button and button:IsVisible() then
                opciones[i] = {
                    Texto = button:GetText() or "Desconocido",
                    Tipo = button.type
                }
            end
        end
        
        -- Guardar opciones de misiones disponibles (por cada botón disponible de misión)
        local misionesDisponibles = {}
        local indiceDisponibles = 1
        
        -- Guardar opciones de misiones activas (por cada botón activo de misión)
        local misionesActivas = {}
        local indiceActivas = 1
        
        -- Recorrer todos los botones y guardar los que sean de misiones
        for i = 1, numOpciones do
            local button = getglobal("GossipTitleButton" .. i)
            if button and button:IsVisible() then
                local texto = button:GetText() or "Desconocido"
                local tipo = button.type
                
                -- Los tipos de botones de misión en Vanilla son "Available" y "Active"
                if tipo == "Available" then
                    misionesDisponibles[indiceDisponibles] = texto
                    indiceDisponibles = indiceDisponibles + 1
                elseif tipo == "Active" then
                    misionesActivas[indiceActivas] = texto
                    indiceActivas = indiceActivas + 1
                end
            end
        end
        
        -- Generar ID único basado en el hash del nombre del NPC (sin prefijo GOSSIP-)
        local gossipID = npcID
        
        -- Verificar si ya existe
        if MisionCacheDB[gossipID] and MisionCacheDB[gossipID].Texto == textoGossip then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[MisionCache]|r Gossip ya capturado para " .. npcNombre)
            return
        end
        
        -- Debug del ID generado - usar la función Debug
        Debug("Hash generado para NPC: " .. npcID .. " (" .. npcNombre .. ")")
        
        -- Guardar datos con formato estandarizado
        GuardarDatos(gossipID, "gossip", npcNombre, textoGossip, "", npcNombre, npcID)
        
        -- Guardar opciones y misiones como propiedades adicionales
        MisionCacheDB[gossipID].Opciones = opciones
        MisionCacheDB[gossipID].MisionesDisponibles = misionesDisponibles
        MisionCacheDB[gossipID].MisionesActivas = misionesActivas
        
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[MisionCache]|r Gossip capturado de " .. npcNombre)
    
    elseif event == "CHAT_MSG_MONSTER_SAY" or event == "CHAT_MSG_MONSTER_YELL" then
        -- Cuando un NPC dice algo (bocadillo) o grita
        local mensaje = arg1 or "" -- El contenido del mensaje
        local npcNombre = arg2 or "Desconocido" -- El nombre del NPC
        local tipoMensaje
        
        if event == "CHAT_MSG_MONSTER_SAY" then
            tipoMensaje = "bocadillo"
        elseif event == "CHAT_MSG_MONSTER_YELL" then
            tipoMensaje = "grito"
        end
        
        -- Generar ID único para el NPC
        local npcID = GenerarHashID(npcNombre)
        if npcID == "0" or npcID == "" then
            npcID = GenerarHashID(npcNombre .. time())
        end
        
        -- Generar ID único para el mensaje
        local mensajeID = GenerarHashID(npcNombre .. mensaje .. tipoMensaje)
        if mensajeID == "0" or mensajeID == "" then
            mensajeID = GenerarHashID(npcNombre .. mensaje .. tipoMensaje .. time())
        end
        
        -- Texto descriptivo según el tipo de mensaje
        local textoTipo = tipoMensaje == "bocadillo" and "Bocadillo" or "Grito"
        
        -- Verificar si ya existe
        if MisionCacheDB[mensajeID] then
            -- Mostrar mensaje solo si está activado el modo debug
            if MisionCacheConfig.debug then
                DEFAULT_CHAT_FRAME:AddMessage("|cFF888888[MisionCache]|r " .. textoTipo .. " ya capturado de " .. npcNombre)
            end
            return -- No guardar duplicados
        end
        
        -- Para bocadillos y gritos, no necesitamos titulo ni objetivos
        -- Crear cada campo en el orden exacto deseado y solo los necesarios
        MisionCacheDB[mensajeID] = {}
        MisionCacheDB[mensajeID].Evento = tipoMensaje
        MisionCacheDB[mensajeID].Texto = mensaje
        MisionCacheDB[mensajeID].NPC = {}
        MisionCacheDB[mensajeID].NPC.ID = npcID
        MisionCacheDB[mensajeID].NPC.Nombre = npcNombre
        
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[MisionCache]|r " .. textoTipo .. " capturado de " .. npcNombre)
    end
end

-- Establecer el controlador de eventos
MisionFrame:SetScript("OnEvent", OnEvent)

-- Función para obtener todas las misiones guardadas (puede ser llamada desde scripts o la consola)
function ObtenerMisionesGuardadas()
    return MisionCacheDB
end

-- Función para obtener información detallada de una misión específica
function ObtenerMision(misionID)
    if MisionCacheDB[misionID] then
        return MisionCacheDB[misionID]
    end
    return nil
end

-- Función para formatear los datos en el orden correcto
function FormatearDatos()
    for id, mision in pairs(MisionCacheDB) do
        local datosFormateados = {}
        
        -- Crear en el orden exacto
        datosFormateados.Evento = mision.Evento
        datosFormateados.Titulo = mision.Titulo
        datosFormateados.Texto = mision.Texto
        datosFormateados.NPC = mision.NPC
        datosFormateados.Objetivos = mision.Objetivos
        
        -- Si hay propiedades adicionales, añadirlas al final
        for k, v in pairs(mision) do
            if k ~= "Evento" and k ~= "Titulo" and k ~= "Texto" and 
               k ~= "NPC" and k ~= "Objetivos" then
                datosFormateados[k] = v
            end
        end
        
        -- Reemplazar con los datos formateados
        MisionCacheDB[id] = datosFormateados
    end
    
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[MisionCache]|r Datos formateados correctamente.")
end

-- Modificar la función ImprimirMisiones para que no formatee datos y solo muestre en el frame
function ImprimirMisiones()
    -- Mostrar el frame de opciones que contiene la lista de misiones
    CrearMenuOpciones()
end

-- Registrar comandos
SLASH_MISIONCACHE1 = "/mc"

SlashCmdList["MISIONCACHE"] = function(msg)
    -- Procesar argumentos
    local command = strlower(msg or "")
    
    -- Comando debug
    if command == "debug" then
        -- Alternar estado de depuración
        MisionCacheConfig.debug = not MisionCacheConfig.debug
        
        if MisionCacheConfig.debug then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[MisionCache]|r Modo de depuración |cFF00FF00ACTIVADO|r. Verás mensajes detallados sobre la captura de datos.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[MisionCache]|r Modo de depuración |cFFFF0000DESACTIVADO|r.")
        end
        return
    -- Comando clear para borrar base de datos
    elseif command == "clear" then
        -- Guardar el nombre de cuenta actual antes de limpiar
        local accountName = MisionCacheDB.AccountName
        
        -- Limpiar la base de datos y restaurar el nombre de cuenta
        MisionCacheDB = {AccountName = accountName}
        
        -- Mostrar mensaje con contador de capturas
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[MisionCache]|r Base de datos limpiada.")
        
        -- Mostrar mensaje de contador de misiones en amarillo
        local contador = 0
        for id, mision in pairs(MisionCacheDB) do
            if id ~= "AccountName" then
                contador = contador + 1
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[MisionCache]|r Total Capturas: " .. contador)
        return
    -- Comando por defecto (sin argumentos) muestra la ventana de opciones
    elseif command == "" then
        ImprimirMisiones()
        return
    -- Mostrar ayuda si no se reconoce el comando
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[MisionCache]|r Comandos disponibles:")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/mc|r - Muestra la ventana principal")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/mc clear|r - Limpia la base de datos")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00/mc debug|r - Activa/desactiva el modo depuración")
    end
end

-- Función para contar las misiones guardadas y mostrarlas en el chat
function ActualizarContador()
    local contador = 0
    local progressCount = 0
    local completeCount = 0
    local detailCount = 0
    local gossipCount = 0
    local bocadilloCount = 0
    local gritoCount = 0
    
    for id, mision in pairs(MisionCacheDB) do
        if id ~= "AccountName" then -- Ignorar la entrada de AccountName
            if mision.Evento == "detail" then
                contador = contador + 1
                detailCount = detailCount + 1
            elseif mision.Evento == "complete" then
                contador = contador + 1
                completeCount = completeCount + 1
            elseif mision.Evento == "progress" then
                contador = contador + 1
                progressCount = progressCount + 1
            elseif mision.Evento == "gossip" then
                gossipCount = gossipCount + 1
            elseif mision.Evento == "bocadillo" then
                bocadilloCount = bocadilloCount + 1
            elseif mision.Evento == "grito" then
                gritoCount = gritoCount + 1
            end
        end
    end
    
    -- Mostrar mensaje en el chat con los totales
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[MisionCache]|r Total Capturas: " .. (contador + gossipCount + bocadilloCount + gritoCount))
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00[MisionCache]|r Detail: " .. detailCount .. " | Progress: " .. progressCount .. " | Complete: " .. completeCount .. " | Gossip: " .. gossipCount .. " | Bocadillos: " .. bocadilloCount .. " | Gritos: " .. gritoCount)
    
    return contador, detailCount, progressCount, completeCount, gossipCount, bocadilloCount, gritoCount
end 