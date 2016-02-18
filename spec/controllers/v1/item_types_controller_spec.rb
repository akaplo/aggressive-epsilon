require 'rails_helper'

describe V1::ItemTypesController do
  describe 'GET #index' do
    before(:each) { authenticate! }
    let(:item_type) { create :item_type }
    let!(:item_1) { create :item, item_type: item_type }
    let!(:item_2) { create :item, item_type: item_type }
    let(:submit) { get :index }
    it 'renders all item types' do
      submit
      json = JSON.parse response.body
      expect(json).to eql(
        [{ 'id' => item_type.id,
           'name' => item_type.name,
           'allowed_keys' => item_type.allowed_keys.map(&:to_s),
           'items' => [{ 'name' => item_1.name },
                       { 'name' => item_2.name }] }])
    end
  end

  describe 'GET #show' do
    before(:each) { authenticate! }
    let(:submit) { get :show, id: item_type.id }
    context 'item type found' do
      let(:item_type) { create :item_type }
      let!(:item_1) { create :item, item_type: item_type }
      let!(:item_2) { create :item, item_type: item_type }
      it 'includes item type and item attributes' do
        submit
        json = JSON.parse response.body
        expect(json).to eql(
          'id' => item_type.id,
          'name' => item_type.name,
          'allowed_keys' => item_type.allowed_keys.map(&:to_s),
          'items' => [{ 'id' => item_1.id,
                        'name' => item_1.name },
                      { 'id' => item_2.id,
                        'name' => item_2.name }])
      end
    end
    context 'item type not found' do
      let(:item_type) { double id: 0 }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'PUT #update' do
    before(:each) { authenticate! }
    let(:changes) { { name: 'A new name' } }
    let(:submit) { put :update, id: item_type.id, item_type: changes }
    context 'item type found' do
      let(:item_type) { create :item_type }
      context 'change applied successfully' do
        it 'calls #update on the item type with the changes' do
          expect_any_instance_of(ItemType)
            .to receive(:update)
            .with(changes.stringify_keys)
            .and_call_original
          submit
        end
        it 'has an OK status' do
          submit
          expect(response).to have_http_status :ok
        end
        it 'has an empty response body' do
          submit
          expect(response.body).to be_empty
        end
      end
      context 'change not applied successfully' do
        let(:changes) { { name: nil } }
        let(:error_messages) { ["Name can't be blank"] }
        it 'has an unprocessable entity status' do
          submit
          expect(response).to have_http_status :unprocessable_entity
        end
        it 'responds with an object containing the item type errors' do
          submit
          json = JSON.parse response.body
          expect(json).to eql 'errors' => error_messages
        end
      end
    end
    context 'item type not found' do
      let(:item_type) { double id: 0 }
      it 'has a not found status' do
        submit
        expect(response).to have_http_status :not_found
      end
    end
  end
end
