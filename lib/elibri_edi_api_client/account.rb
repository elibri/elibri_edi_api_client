module ElibriEdiApiClient
  class Account < Base

    def_attributes :accessible_companies

    def self.get
      o = new({})
      o.get "v1/account_info"
      o
    end
  end
end
