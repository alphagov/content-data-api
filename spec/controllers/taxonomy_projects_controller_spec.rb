RSpec.describe TaxonomyProjectsController, type: :controller do
  include AuthenticationControllerHelpers

  before do
    login_as_stub_user
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "renders the :index template" do
      get :index
      expect(subject).to render_template(:index)
    end
  end

  describe "GET #show" do
    let(:project) { TaxonomyProject.create }

    before do
      get :show, params: { id: project.id }
    end

    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "assigns current project" do
      expect(assigns(:project)).to eq(project)
    end

    it "renders the :show template" do
      expect(subject).to render_template(:show)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "creates a new project and redirects to the project" do
      project = TaxonomyProject.create
      expect(TermGeneration::TaxonomyProjectBuilder).to receive(:build).with(name: 'project_name', csv_url: 'csv_url').and_return project
      post :create, params: { name: 'project_name', csv_url: 'csv_url' }
      expect(response).to redirect_to(taxonomy_project_path(project))
    end
  end

  describe "GET #next" do
    before :each do
      @project = TaxonomyProject.create
    end
    it 'redirects to the next todo' do
      todo = @project.taxonomy_todos.create(content_item: create(:content_item))
      get :next, params: { id: @project.id }
      expect(response).to redirect_to(todo)
    end

    it 'is all done' do
      @project = TaxonomyProject.create
      get :next, params: { id: @project.id }
      expect(response).to redirect_to(@project)
    end
  end
end
