Rails.application.config.middleware.insert_after ActionDispatch::Static, Rack::Deflater
