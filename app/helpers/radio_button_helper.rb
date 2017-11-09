module RadioButtonHelper
  def audit_status_radio_button_options(selected)
    options = [
      { value: Audits::Audit::NON_AUDITED.to_s, label: 'Not audited' },
      { value: Audits::Audit::AUDITED.to_s, label: 'Audited' },
      { value: Audits::Audit::ALL.to_s, label: 'All' },
    ]

    options.map.with_index do |option, index|
      option.merge(
        id: "audit_status_#{option[:value]}",
        selected: selected == option[:value] || index.zero?,
      )
    end
  end
end
