FactoryGirl.define do
  factory :publication, class: Publication, parent: :document do
    title "publication-title"
    body  "publication-body"
    summary "publication-summary"
    publication_date { 10.days.ago }

    trait(:corporate) { corporate_publication true }
  end

  factory :draft_publication, parent: :publication, traits: [:draft]
  factory :submitted_publication, parent: :publication, traits: [:submitted]
  factory :rejected_publication, parent: :publication, traits: [:rejected]
  factory :published_publication, parent: :publication, traits: [:published]
  factory :deleted_publication, parent: :publication, traits: [:deleted]
  factory :archived_publication, parent: :publication, traits: [:archived]

  factory :featured_publication, parent: :publication, traits: [:published, :featured]

  factory :draft_corporate_publication, parent: :publication, traits: [:draft, :corporate]
  factory :submitted_corporate_publication, parent: :publication, traits: [:submitted, :corporate]
  factory :published_corporate_publication, parent: :publication, traits: [:published, :corporate]
end