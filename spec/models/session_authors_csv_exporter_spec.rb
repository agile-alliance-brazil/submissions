# frozen_string_literal: true

require 'spec_helper'

# TODO: Fix example lengths
# rubocop:disable RSpec/ExampleLength
describe SessionAuthorsCSVExporter do
  HEADERS = "Session id,Session title,Session Type,Author,Email,Phone".freeze

  it 'generates CSV for single session' do
    session = FactoryBot.build(:session)

    exporter = described_class.new([session])

    csv = <<~CSV
      #{HEADERS}
      #{csv_row_for(session, session.author)}
    CSV
    expect(exporter.to_csv).to eq(csv)
  end

  it 'generates CSV with two rows for single session with two authors' do
    session = FactoryBot.build(:session)
    session.second_author = FactoryBot.build(:author)

    exporter = described_class.new([session])

    csv = <<~CSV
      #{HEADERS}
      #{csv_row_for(session, session.author)}
      #{csv_row_for(session, session.second_author)}
    CSV
    expect(exporter.to_csv).to eq(csv)
  end

  it 'generates CSV with three rows for one session with one author and another with two' do
    single_author_session = FactoryBot.build(:session)
    two_authors_session = FactoryBot.build(:session)
    two_authors_session.second_author = FactoryBot.build(:author)

    exporter = described_class.new([single_author_session, two_authors_session])

    csv = <<~CSV
      #{HEADERS}
      #{csv_row_for(single_author_session, single_author_session.author)}
      #{csv_row_for(two_authors_session, two_authors_session.author)}
      #{csv_row_for(two_authors_session, two_authors_session.second_author)}
    CSV
    expect(exporter.to_csv).to eq(csv)
  end

  it 'generates sessions sorted by session type id' do
    conference = FactoryBot.build(:conference)
    first_session_type = FactoryBot.build(:session_type, conference: conference)
    first_session_type.id = 1
    last_session_type = FactoryBot.build(:session_type, conference: conference)
    last_session_type.id = 2
    first_session = FactoryBot.build(:session, conference: conference, session_type: last_session_type)
    second_session = FactoryBot.build(:session, conference: conference, session_type: first_session_type)

    exporter = described_class.new([first_session, second_session])

    csv = <<~CSV
      #{HEADERS}
      #{csv_row_for(second_session, second_session.author)}
      #{csv_row_for(first_session, first_session.author)}
    CSV
    expect(exporter.to_csv).to eq(csv)
  end

  it 'generates sessions with one author first and pairs after' do
    first_session = FactoryBot.build(:session)
    first_session.second_author = FactoryBot.build(:author)
    second_session = FactoryBot.build(:session)

    exporter = described_class.new([first_session, second_session])

    csv = <<~CSV
      #{HEADERS}
      #{csv_row_for(second_session, second_session.author)}
      #{csv_row_for(first_session, first_session.author)}
      #{csv_row_for(first_session, first_session.second_author)}
    CSV
    expect(exporter.to_csv).to eq(csv)
  end

  def csv_row_for(session, author)
    "#{session.id},#{session.title},#{I18n.t(session.session_type.title)},#{author.full_name},#{author.email},#{author.phone}"
  end
end
# rubocop:enable RSpec/ExampleLength
