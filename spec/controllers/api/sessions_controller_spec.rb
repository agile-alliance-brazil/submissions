# encoding: UTF-8
require 'spec_helper'

describe Api::V1::SessionsController, type: :controller do
  let(:session)  { FactoryGirl.create(:session, keyword_list: %w(fake tags tags.success)) }

  describe 'show' do
    context 'with pt locale' do
      before do
        get :show, id: session.id.to_s, format: :json, locale: 'pt'
      end

      it { should respond_with(:success) }

      it 'should return session JSON parseable representation' do
        gravatar_id = Digest::MD5::hexdigest(session.author.email).downcase
        expect(JSON.parse(response.body)).to eq({
          'id' => session.id,
          'title' => session.title,
          'authors' => [{ 'name' => session.author.full_name,
            'gravatar_url' => gravatar_url(gravatar_id)}],
          'prerequisites' => session.prerequisites,
          'tags' => ['fake', 'tags', 'Casos de Sucesso'],
          'session_type' => 'Palestra',
          'audience_level' => 'Iniciante',
          'track' => 'Engenharia',
          'summary' => session.summary
        })
      end

      it 'should return session raw JSON with 2 authors' do
        session.second_author = FactoryGirl.create(:author, email: 'dtsato@dtsato.com')
        session.save

        get :show, id: session.id.to_s, format: :json, locale: 'pt'

        expect(response.body).to eq(%Q{
          {
            "id":#{session.id},
            "title":"#{session.title}",
            "authors":[
              {
                "name":"#{session.author.full_name}",
                "gravatar_url":"#{gravatar_url(Digest::MD5::hexdigest(session.author.email).downcase)}"
              },
              {
                "name":"#{session.second_author.full_name}",
                "gravatar_url":"#{gravatar_url('9681863a56f1e1ac9562c72b297f6c2d')}"
              }
            ],
            "prerequisites":"#{session.prerequisites}",
            "tags":["fake","tags","Casos de Sucesso"],
            "session_type":"Palestra",
            "audience_level":"Iniciante",
            "track":"Engenharia",
            "summary":"#{session.summary}"}
        }.gsub(/\s*\n\s*/,''))
      end
    end

    context 'using en locale' do
      before do
        get :show, id: session.id.to_s, format: :json, locale: 'en'
      end
      it 'should respect locale on session type, audience level, track and tags if possible' do
        expect(response.body).to eq(%Q{
          {
            "id":#{session.id},
            "title":"#{session.title}",
            "authors":[
              {
                "name":"#{session.author.full_name}",
                "gravatar_url":"#{gravatar_url(Digest::MD5::hexdigest(session.author.email).downcase)}"
              }
            ],
            "prerequisites":"#{session.prerequisites}",
            "tags":["fake","tags","Success Cases"],
            "session_type":"Lecture",
            "audience_level":"Beginner",
            "track":"Engineering",
            "summary":"#{session.summary}"}
        }.gsub(/\s*\n\s*/,''))
      end
    end
  end
  def gravatar_url(gravatar_id)
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=48&d=mm"
  end
end
