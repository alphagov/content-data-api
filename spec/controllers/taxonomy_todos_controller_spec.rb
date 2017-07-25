RSpec.describe TaxonomyTodosController, type: :controller do
  include AuthenticationControllerHelpers
  before do
    login_as_stub_user
    @taxonomy_todo = FactoryGirl.create(:taxonomy_todo, status: TaxonomyTodo::STATE_TODO)
  end

  describe '#show' do
    it 'renders the show page' do
      get :show, params: { id: @taxonomy_todo.id }
      expect(response).to render_template(:show)
      expect(assigns(:todo_form).errors).to be_empty
    end
    describe 'use flash' do
      it 'renders the show page with errors' do
        session['flash'] = ActionDispatch::Flash::FlashHash.new('taxonomy_todos_params' => { 'terms' => '' })
        get :show, params: { id: @taxonomy_todo.id }
        expect(assigns(:todo_form).errors).to_not be_empty
      end
      it 'renders the show page without  errors' do
        session['flash'] = ActionDispatch::Flash::FlashHash.new('taxonomy_todos_params' => { 'terms' => 'term1, term2' })
        get :show, params: { id: @taxonomy_todo.id }
        expect(assigns(:todo_form).errors).to_not be_empty
      end
    end
  end

  describe '#update' do
    it 'redirect to show with errors because there are no terms' do
      put :update, params: { taxonomy_todo_form: { terms: '' }, id: @taxonomy_todo.id }
      expect(response).to redirect_to(taxonomy_todo_path(@taxonomy_todo.id))
      expect(flash.alert).to_not be_nil
    end

    it 'redirects to the next item' do
      put :update, params: { taxonomy_todo_form: { terms: 'term' }, id: @taxonomy_todo.id }
      expect(response).to redirect_to(next_taxonomy_project_path(@taxonomy_todo.taxonomy_project))
    end

    it 'saves terms to the the taxonomy' do
      expect {
        put :update, params: { taxonomy_todo_form: { terms: 'term1, term2' }, id: @taxonomy_todo.id }
      }.to change { @taxonomy_todo.reload.terms.count }.by(2)
      expect(@taxonomy_todo.terms.map(&:name)).to match_array(%w(term1 term2))
    end
  end

  describe '#dont_know' do
    it 'redirects to the next item' do
      post :dont_know, params: { id: @taxonomy_todo.id }
      expect(response).to redirect_to(next_taxonomy_project_path(@taxonomy_todo.taxonomy_project))
    end
    it 'changes the state of the taxonomy to from STATE_TODO to STATE_DONT_KNOW' do
      expect {
        post :dont_know, params: { id: @taxonomy_todo.id }
      }.to change {
        @taxonomy_todo.reload.status
      }.from(TaxonomyTodo::STATE_TODO).to(TaxonomyTodo::STATE_DONT_KNOW)
    end
  end

  describe '#not_relevant' do
    it 'redirects to the next item' do
      post :not_relevant, params: { id: @taxonomy_todo.id }
      expect(response).to redirect_to(next_taxonomy_project_path(@taxonomy_todo.taxonomy_project))
    end
    it 'changes the state of the taxonomy to from STATE_TODO to STATE_NOT_RELEVANT' do
      expect {
        post :not_relevant, params: { id: @taxonomy_todo.id }
      }.to change {
        @taxonomy_todo.reload.status
      }.from(TaxonomyTodo::STATE_TODO).to(TaxonomyTodo::STATE_NOT_RELEVANT)
    end
  end
end
