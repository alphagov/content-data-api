module RadioButtonHelper
  def audit_status_radio_button_options(selected)
    options = [
      { value: Audits::Audit::NON_AUDITED, label: 'Not audited' },
      { value: Audits::Audit::AUDITED, label: 'Audited' },
      { value: Audits::Audit::ALL, label: 'All' },
    ]

    options.map.with_index do |option, index|
      option.merge(
        id: "audit_status_#{option[:value]}",
        selected: selected.to_s == option[:value].to_s || index.zero?,
      )
    end
  end
end
