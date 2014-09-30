# encoding: UTF-8
require 'spec_helper'

describe ApplicationHelper, type: :helper do
  describe "fix URL" do
    it "should prepend 'http://' if missing" do
      expect(helper.prepend_http('www.dtsato.com')).to eq('http://www.dtsato.com')
    end

    it "should not change URL if starts with 'http://'" do
      expect(helper.prepend_http('http://dtsato.com')).to eq('http://dtsato.com')
    end

    it "should ignore case when fixing" do
      expect(helper.prepend_http('HTTP://dtsato.com/some/path-01')).to eq('HTTP://dtsato.com/some/path-01')
    end

    it "should not prepend on empty string" do
      expect(helper.prepend_http('')).to eq('')
      expect(helper.prepend_http(nil)).to be_nil
      expect(helper.prepend_http('   ')).to eq('   ')
    end
  end

  describe "sort link" do
    before(:each) do
      @params = {controller: :organizer_sessions, action: :index}
    end

    it "should link down if nothing set" do
      expect(helper.sortable_column('test', :id, @params)).to eq('<a href="/organizer_sessions?column=id&amp;direction=down">test</a>')
    end

    it "should link down if was going up on that column" do
      @params[:column] = 'id'
      @params[:direction] = 'up'
      expect(helper.sortable_column('test', :id, @params)).to eq('<a href="/organizer_sessions?column=id&amp;direction=down">test</a>')
    end

    it "should link up if was going down on that column" do
      @params[:column] = 'id'
      @params[:direction] = 'down'
      expect(helper.sortable_column('test', :id, @params)).to eq('<a href="/organizer_sessions?column=id&amp;direction=up">test</a>')
    end

    it "should link down if was going down on another column" do
      @params[:column] = 'author_id'
      @params[:direction] = 'down'
      expect(helper.sortable_column('test', :id, @params)).to eq('<a href="/organizer_sessions?column=id&amp;direction=down">test</a>')
    end

    it "should reset page when sorting is clicked" do
      @params[:column] = 'id'
      @params[:direction] = 'up'
      @params[:page] = 2
      expect(helper.sortable_column('test', :id, @params)).to eq('<a href="/organizer_sessions?column=id&amp;direction=down">test</a>')
    end
  end

  describe "translated_country" do
    it "should return translated country from code" do
      I18n.with_locale('pt') do
        expect(helper.translated_country(:BR)).to eq('Brasil')
        expect(helper.translated_country('US')).to eq('Estados Unidos')
        expect(helper.translated_country('fr')).to eq('França')
      end
    end

    it "should return empty if country is invalid" do
      expect(helper.translated_country('')).to be_empty
      expect(helper.translated_country(nil)).to be_empty
      expect(helper.translated_country(' ')).to be_empty
    end
  end

  describe "translated_state" do
    it "should return translated state from code" do
      I18n.with_locale('pt') do
        expect(helper.translated_state(:SP)).to eq('São Paulo')
        expect(helper.translated_state('RJ')).to eq('Rio de Janeiro')
      end
    end

    it "should return empty if state is invalid" do
      expect(helper.translated_state('')).to be_empty
      expect(helper.translated_state(nil)).to be_empty
      expect(helper.translated_state(' ')).to be_empty
      expect(helper.translated_state('SS')).to be_empty
    end
  end

  describe "present_date" do
    before :each do
      @date = Time.zone.now
      @conference = Conference.new
    end

    it "should make date bold if next deadline matches" do
      @conference.expects(:next_deadline).returns([@date, :submissions_deadline])
      expect(helper.present_date(@conference, [@date, :submissions_deadline])).to eq("<strong>#{l(@date.to_date)}: #{t('conference.dates.submissions_deadline')}</strong>")
    end

    it "should leave date if next deadline doesn't matches" do
      @conference.expects(:next_deadline).returns([@date + 1, :author_notification])
      expect(helper.present_date(@conference, [@date, :submissions_deadline])).to eq("#{l(@date.to_date)}: #{t('conference.dates.submissions_deadline')}")
    end

    it "should leave date if next deadline is nil" do
      @conference.expects(:next_deadline).returns(nil)
      expect(helper.present_date(@conference, [@date, :submissions_deadline])).to eq("#{l(@date.to_date)}: #{t('conference.dates.submissions_deadline')}")
    end
  end
end
