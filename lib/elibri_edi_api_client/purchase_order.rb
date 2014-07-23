module ElibriEdiApiClient
  class PurchaseOrder < Base
    ##
    # Używać w następujący sposób:
    # # przygotować hash z danymi zgodnie ze specyfikacją API
    # data = { ... }
    # order = ElibriEdiApiClient::PurchaseOrder.create(data)
    # order.read #pobiera (aktualizuje) dane z EDI
    #
    # order = ElibriEdiApiClient::PurchaseOrder.find(7) #pobiera dane zamówienia o podanym id
    # 

    #TODO: podczas tworzenia obiektu podać gdzieś wersję, żeby nie 
    #dawać na sztywno w wywołaniach
    def self.create(data)
      o = new(data)
      o.post 'v1/purchase_orders'
      o
    end

    def self.find(id_or_data)
      o = new(id_or_data)
      o.get "v1/purchase_orders/:id"
      o
    end

    def create_message(data)
      klass = klass_from_kind(data[:kind])
      o = klass.new(data)
      url = self.url_for 'v1/purchase_orders/:id/messages'
      o.post url
    end

    # prawdopodobnie do wywalenia
    def ediex_process(ediex_name)
      enqueue_ediex_process ediex_name
    end

    private
    # prawdopodobnie do wywalenia
    def enqueue_ediex_process(ediex_name)
      job_class = "#{ediex_name}::ResqueJob::ProcessNewOrder".constantize
      Resque.enqueue job_class, self[:id]
    end
  end
end
