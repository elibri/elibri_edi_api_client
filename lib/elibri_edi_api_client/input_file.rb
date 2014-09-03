module ElibriEdiApiClient
  class InputFile < Base

    # get :find, "/input_files/:id"
    # put :update, "/input_files/:id"

    def self.find(id_or_data)
      i = new(id_or_data)
      i.get "v1/input_files/:id"
      i
    end

    def update_state(state)
      self[:state]=state
      put "v1/input_files/:id"
      self
    end
  end
end
