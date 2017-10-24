module RadioButtonHelper
  def audit_status_radio_button_options(selected)
    options = [
      { value: Audits::Audit::ALL, label: 'All' },
      { value: Audits::Audit::AUDITED, label: 'Audited' },
      { value: Audits::Audit::NON_AUDITED, label: 'Not audited' },
    ]

    options.map.with_index do |option, index|
      option.merge(
        id: "audit_status_#{option[:value]}",
        selected: selected == option[:value] || index.zero?,
      )
    end
  end
end
