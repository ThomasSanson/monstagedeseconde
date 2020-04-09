# frozen_string_literal: true

require 'test_helper'
class SyncInternshipOfferKeywordsJobTest < ActiveJob::TestCase
  test 'insert all keywords' do
    create(:internship_offer, title: "hello", description: "boom", employer_description: "bim")

    assert_changes -> {InternshipOfferKeyword.count},
                  from: 0,
                  to: 3 do
      SyncInternshipOfferKeywordsJob.perform_now
    end
  end

  test 'upsert old keyword maintain ndoc counter and searchable' do
    create(:internship_offer, title: "hello", description: "boom", employer_description: "bim")
    SyncInternshipOfferKeywordsJob.perform_now
    hello_keyword = InternshipOfferKeyword.where(word: "hello").first
    hello_keyword.update!(searchable: false)
    create(:internship_offer, title: "hello", description: "boom", employer_description: "bim")

    assert_changes -> { hello_keyword.reload.ndoc },
                  from: 1,
                  to: 2 do
      SyncInternshipOfferKeywordsJob.perform_now
    end
    refute hello_keyword.searchable
  end

  test 'upsert new keyword works' do
    create(:internship_offer, title: "hello", description: "boom", employer_description: "bim")
    SyncInternshipOfferKeywordsJob.perform_now
    create(:internship_offer, title: "new", description: "boom", employer_description: "bim")

    assert_changes -> { InternshipOfferKeyword.count },
                  from: 3,
                  to: 4 do
      SyncInternshipOfferKeywordsJob.perform_now
    end
  end
end
