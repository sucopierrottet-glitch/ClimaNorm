/// Trilingual localization dictionary (ES, EN, PT) for ClimaNorm Pro.
/// Offline-first, zero external asset loading delay.
class AppStrings {
  final String code;

  const AppStrings(this.code);

  static AppStrings get(String localeCode) {
    final clean = localeCode.toLowerCase();
    if (clean.startsWith('en')) return const AppStrings('en');
    if (clean.startsWith('pt')) return const AppStrings('pt');
    return const AppStrings('es');
  }

  String _t(String es, String en, String pt) {
    if (code == 'en') return en;
    if (code == 'pt') return pt;
    return es;
  }

  // Branding & Welcome Screen
  String get appTitle => 'CLIMANORM PRO';
  String get appSubtitle => _t(
        'Cálculo de Carga Térmica BTU/h, P-T & Diagnóstico HVAC',
        'BTU/h Thermal Load, P-T Chart & HVAC Diagnostics',
        'Carga Térmica BTU/h, Tabela P-T & Diagnóstico HVAC',
      );
  String get enterApp => _t('Entrar a ClimaNorm', 'Enter ClimaNorm', 'Entrar no ClimaNorm');
  String get newCalculation => _t('+ Nuevo Cálculo HVAC', '+ New HVAC Calculation', '+ Novo Cálculo HVAC');
  String get proEditionBadge => _t(
        'EDICIÓN PRO DESBLOQUEADA • 100% OFFLINE',
        'PRO EDITION UNLOCKED • 100% OFFLINE',
        'EDIÇÃO PRO DESBLOQUEADA • 100% OFFLINE',
      );

  // Navigation Tabs
  String get tabThermal => _t('Carga BTU', 'BTU Load', 'Carga BTU');
  String get tabPtDiag => _t('P-T & Gases', 'P-T & Gas', 'P-T & Gás');
  String get tabProjects => _t('Proyectos', 'Projects', 'Projetos');
  String get tabSettings => _t('Ajustes', 'Settings', 'Ajustes');

  // Thermal Load Calculator Screen
  String get thermalTitle => _t(
        'Calculadora de Carga Térmica HVAC',
        'HVAC Thermal Load Calculator',
        'Calculadora de Carga Térmica HVAC',
      );
  String get roomDimensionsSection => _t(
        'DIMENSIONES Y CLIMA DEL RECINTO',
        'ROOM DIMENSIONS & CLIMATE',
        'DIMENSÕES E CLIMA DO AMBIENTE',
      );
  String get areaLabel => _t('Área del Recinto', 'Room Area', 'Área do Ambiente');
  String get ceilingHeightLabel => _t('Altura de Techo (m)', 'Ceiling Height (m)', 'Pé-Direito / Altura (m)');
  String get climateZoneLabel => _t('Zona Climática', 'Climate Zone', 'Zona Climática');
  String get sunExposureLabel => _t('Exposición Solar', 'Sun Exposure', 'Exposição Solar');
  String get internalLoadsSection => _t(
        'CARGAS INTERNAS (OCUPANTES Y EQUIPOS)',
        'INTERNAL LOADS (OCCUPANTS & APPLIANCES)',
        'CARGAS INTERNAS (OCUPANTES E EQUIPAMENTOS)',
      );
  String get occupantsLabel => _t('Ocupantes (Personas)', 'Occupants (People)', 'Ocupantes (Pessoas)');
  String get appliancesWattsLabel => _t(
        'Equipos / Iluminación (W)',
        'Appliances / Lighting (W)',
        'Equipamentos / Iluminação (W)',
      );

  // Climate Zones
  String get climateCold => _t('Frío', 'Cold', 'Frio');
  String get climateTemperate => _t('Templado', 'Temperate', 'Temperado');
  String get climateHot => _t('Cálido', 'Hot', 'Quente');
  String get climateTropical => _t('Tropical / Extremo', 'Tropical / Extreme', 'Tropical / Extremo');

  // Sun Exposure
  String get sunLow => _t('Baja / Sombra', 'Low / Shade', 'Baixa / Sombra');
  String get sunModerate => _t('Media / Parcial', 'Moderate / Partial', 'Média / Parcial');
  String get sunHigh => _t('Alta / Sol Directo', 'High / Direct Sun', 'Alta / Sol Direto');

  // Thermal Results
  String get totalThermalLoadLabel => _t('CARGA TÉRMICA TOTAL', 'TOTAL THERMAL LOAD', 'CARGA TÉRMICA TOTAL');
  String get frigoriasLabel => _t('Frigorías/h', 'Frigorias/h', 'Frigorias/h');
  String get thermalKwLabel => _t('Potencia (kW)', 'Capacity (kW)', 'Potência (kW)');
  String get recommendedTonnageLabel => _t(
        'Equipo Recomendado',
        'Recommended Unit',
        'Equipamento Recomendado',
      );
  String get saveProjectBtn => _t('Guardar Proyecto', 'Save Project', 'Salvar Projeto');
  String get exportPdfBtn => _t('Generar Reporte PDF', 'Generate PDF Report', 'Gerar Relatório PDF');

  // P-T & Superheat/Subcooling Screen
  String get ptScreenTitle => _t(
        'Presión-Temperatura (P-T) y Diagnóstico',
        'Pressure-Temperature (P-T) & Diagnostics',
        'Pressão-Temperatura (P-T) e Diagnóstico',
      );
  String get selectRefrigerantLabel => _t(
        'SELECCIONAR GAS REFRIGERANTE',
        'SELECT REFRIGERANT GAS',
        'SELECIONAR GÁS REFRIGERANTE',
      );
  String get suctionGaugeLabel => _t(
        'Presión Succión / Baja (PSIG)',
        'Suction / Low Pressure (PSIG)',
        'Pressão Sucção / Baixa (PSIG)',
      );
  String get suctionLineTempLabel => _t(
        'Temp. Tubo Succión (°C)',
        'Suction Line Temp (°C)',
        'Temp. Linha Sucção (°C)',
      );
  String get liquidGaugeLabel => _t(
        'Presión Líquido / Alta (PSIG)',
        'Liquid / High Pressure (PSIG)',
        'Pressão Líquido / Alta (PSIG)',
      );
  String get liquidLineTempLabel => _t(
        'Temp. Línea Líquido (°C)',
        'Liquid Line Temp (°C)',
        'Temp. Linha Líquido (°C)',
      );
  String get superheatLabel => _t('Recalentamiento (SH)', 'Superheat (SH)', 'Superaquecimento (SH)');
  String get subcoolingLabel => _t('Subenfriamiento (SC)', 'Subcooling (SC)', 'Sub-resfriamento (SC)');
  String get evapSatTempLabel => _t('T. Sat Evaporador', 'Evap Sat Temp', 'T. Sat Evaporador');
  String get condSatTempLabel => _t('T. Sat Condensador', 'Cond Sat Temp', 'T. Sat Condensador');

  // Diagnostic Verdicts
  String get verdictUndercharged => _t(
        'FALTA DE CARGA (SUBCARGADO)',
        'UNDERCHARGED (LOW REFRIGERANT)',
        'BAIXA CARGA (SUBCARREGADO)',
      );
  String get verdictOptimal => _t(
        'CARGA ÓPTIMA (DENTRO DE NORMA)',
        'OPTIMAL CHARGE (COMPLIANT)',
        'CARGA ÓTIMA (DENTRO DA NORMA)',
      );
  String get verdictOvercharged => _t(
        'EXCESO DE CARGA (SOBRECARGADO)',
        'OVERCHARGED (EXCESS REFRIGERANT)',
        'EXCESSO DE CARGA (SOBRECARREGADO)',
      );
  String get verdictDescUndercharged => _t(
        'Recalentamiento elevado (>12 K) o subenfriamiento bajo (<3 K). Verifique fugas y agregue refrigerante gradualmente.',
        'High superheat (>12 K) or low subcooling (<3 K). Check for leaks and add refrigerant gradually.',
        'Superaquecimento alto (>12 K) ou sub-resfriamento baixo (<3 K). Verifique vazamentos e adicione gás.',
      );
  String get verdictDescOptimal => _t(
        'Recalentamiento (4–12 K) y subenfriamiento (3–9 K) en rango normativo ASHRAE / fabricante.',
        'Superheat (4–12 K) and subcooling (3–9 K) within ASHRAE / OEM operating targets.',
        'Superaquecimento (4–12 K) e sub-resfriamento (3–9 K) dentro dos padrões ASHRAE / fabricante.',
      );
  String get verdictDescOvercharged => _t(
        'Recalentamiento muy bajo (<4 K, riesgo de retorno líquido al compresor) o subenfriamiento alto (>9 K). Recupere excedente.',
        'Very low superheat (<4 K, liquid floodback risk) or high subcooling (>9 K). Recover excess charge.',
        'Superaquecimento muito baixo (<4 K, risco de golpe de líquido) ou sub-resfriamento alto (>9 K). Recupere o excesso.',
      );

  // Saved Projects Screen
  String get savedProjectsTitle => _t(
        'Proyectos HVAC Guardados',
        'Saved HVAC Projects',
        'Projetos HVAC Salvos',
      );
  String get noSavedProjects => _t(
        'Aún no hay proyectos HVAC guardados.\nGuarda un cálculo desde la pestaña Carga BTU o P-T.',
        'No saved HVAC projects yet.\nSave a calculation from the BTU Load or P-T tab.',
        'Nenhum projeto HVAC salvo ainda.\nSalve um cálculo na aba Carga BTU ou P-T.',
      );
  String get projectTitleLabel => _t('Nombre del Proyecto / Sala', 'Project / Room Name', 'Nome do Projeto / Sala');
  String get clientNameLabel => _t('Cliente / Empresa', 'Client / Company', 'Cliente / Empresa');
  String get siteAddressLabel => _t('Ubicación / Obra', 'Site / Location', 'Local / Obra');
  String get signAndExportPdf => _t('Firmar y Exportar PDF', 'Sign & Export PDF', 'Assinar e Exportar PDF');
  String get loadProjectBtn => _t('Cargar en Calculadora', 'Load in Calculator', 'Carregar na Calculadora');
  String get deleteProjectBtn => _t('Eliminar', 'Delete', 'Excluir');

  // Settings Screen
  String get settingsTitle => _t('Ajustes y Perfil Técnico', 'Settings & Tech Profile', 'Ajustes e Perfil Técnico');
  String get languageHeader => _t('IDIOMA / LANGUAGE', 'LANGUAGE', 'IDIOMA');
  String get proActiveTitle => _t(
        'ClimaNorm Pro — Licencia Completa Activa',
        'ClimaNorm Pro — Full License Active',
        'ClimaNorm Pro — Licença Completa Ativa',
      );
  String get proActiveSubtitle => _t(
        'Cálculos BTU/h ilimitados, Tablas P-T y Reportes PDF Firmados desbloqueados.',
        'Unlimited BTU/h calculations, P-T Charts & Signed PDF Reports unlocked.',
        'Cálculos BTU/h ilimitados, Tabelas P-T e Relatórios PDF Assinados liberados.',
      );
  String get technicianProfileHeader => _t(
        'PERFIL DEL INGENIERO / TÉCNICO HVAC',
        'HVAC ENGINEER / TECHNICIAN PROFILE',
        'PERFIL DO ENGENHEIRO / TÉCNICO HVAC',
      );
  String get technicianProfileDesc => _t(
        'Estos datos aparecerán en el encabezado y bloque de firma de tus memorias técnicas PDF.',
        'These details will appear on the header and signature block of your PDF technical reports.',
        'Estes dados aparecerão no cabeçalho e bloco de assinatura dos seus relatórios técnicos em PDF.',
      );
  String get technicianNameLabel => _t('Nombre del Ingeniero / Técnico', 'Engineer / Technician Name', 'Nome do Engenheiro / Técnico');
  String get companyNameLabel => _t('Empresa / Contratista HVAC', 'HVAC Company / Contractor', 'Empresa / Empreiteira HVAC');
  String get licenseNumberLabel => _t('Matrícula / Certificación EPA / RITE', 'License / EPA / Certification ID', 'Registro CREA / Certificação');
  String get phoneLabel => _t('Teléfono de Contacto', 'Contact Phone', 'Telefone de Contato');
  String get emailLabel => _t('Correo Electrónico', 'Email Address', 'E-mail');
  String get saveSettingsBtn => _t('Guardar Perfil Técnico', 'Save Technical Profile', 'Salvar Perfil Técnico');
  String get settingsSavedSuccess => _t(
        'Perfil técnico guardado correctamente',
        'Technical profile saved successfully',
        'Perfil técnico salvo com sucesso',
      );
  String get signatureSectionHeader => _t(
        'FIRMA DIGITAL PREDETERMINADA',
        'DEFAULT DIGITAL SIGNATURE',
        'ASSINATURA DIGITAL PADRÃO',
      );
  String get configureSignatureBtn => _t(
        'Configurar Firma Digital del Técnico / Ingeniero',
        'Set Up Default Technician / Engineer Signature',
        'Configurar Assinatura Digital do Técnico',
      );
  String get technicalStandardsHeader => _t(
        'NORMATIVAS HVAC APLICADAS',
        'APPLIED HVAC STANDARDS',
        'NORMAS HVAC APLICADAS',
      );
  String get technicalStandardsDesc => _t(
        'Motor determinista calibrado conforme a estándares internacionales de climatización y refrigeración:',
        'Deterministic engine calibrated according to international HVAC&R engineering standards:',
        'Motor determinístico calibrado conforme normas internacionais de climatização e refrigeração:',
      );
  String get privacyPolicyBtn => _t('Política de Privacidad', 'Privacy Policy', 'Política de Privacidade');
  String get appVersion => 'ClimaNorm Pro v1.0.0+1 (Offline-First)';
  String get save => _t('Guardar', 'Save', 'Salvar');
  String get cancel => _t('Cancelar', 'Cancel', 'Cancelar');
}
