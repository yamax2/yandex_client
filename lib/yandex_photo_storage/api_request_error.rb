module YandexPhotoStorage
  class ApiRequestError < StandardError
    attr_reader :error, :error_description, :code

    def initialize(error:, error_description:, code:)
      @error = error
      @error_description = error_description
      @code = code

      super [error, error_description, "http code #{@code}"].compact.join(', ')
    end
  end
end
