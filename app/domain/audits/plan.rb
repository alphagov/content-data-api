module Audits
  class Plan
    def self.document_type_ids
      DOCUMENT_TYPES.values
    end

    def self.document_types
      DOCUMENT_TYPES
    end

    def self.auditors(exclude: nil)
      User.all - Array(exclude)
    end

    DOCUMENT_TYPES = {
      "Answer" => :answer,
      "Case Study > Case Study" => :case_study,
      "Consultation > Closed Consultation" => :closed_consultation,
      "Consultation > Consultation Outcome" => :consultation_outcome,
      "Publication > Corporate Report" => :corporate_report,
      "Publication > Correspondence" => :correspondence,
      "Publication > Decision" => :decision,
      "Detailed Guidance > Detailed Guide" => :detailed_guide,
      "Document Collection > Collection" => :document_collection,
      "Publication > Form" => :form,
      "Publication > Guidance" => :guidance,
      "Guide" => :guide,
      "Publication > Impact Assessment" => :impact_assessment,
      "Publication > Independent Report" => :independent_report,
      "Publication > International Treaty" => :international_treaty,
      "Mainstream Browse Page" => :mainstream_browse_page,
      "Manual" => :manual,
      "Manual Section" => :manual_section,
      "Publication > Map" => :map,
      "Publication > Notice" => :notice,
      "Consultation > Open Consultation" => :open_consultation,
      "Publication > Policy Paper" => :policy_paper,
      "Publication > Promotional Material" => :promotional,
      "Publication > Regulation" => :regulation,
      "Publication > Research And Analysis" => :research,
      "Simple Smart Answer" => :simple_smart_answer,
      "Smart-answer" => :smart_answer,
      "Publication > Statutory Guidance" => :statutory_guidance,
      "Transaction" => :transaction,
      "Publication > Transparency Data" => :transparency,
    }.freeze
    private_constant :DOCUMENT_TYPES
  end
end
