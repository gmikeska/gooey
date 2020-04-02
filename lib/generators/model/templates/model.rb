<%=%Q(class #{singular_name.capitalize} < #{parent_model_name}
  #{render_declared_attrs}
  #{render_method('upload(params)',
 %Q(if(params[:files])
      files.attach(params[:files])
    end),'gallery')}
  #{render_method('get_url(filename)',
 %Q(files = self.files.select {|f| f.filename == filename }
    return Rails.application.routes.url_helpers.rails_blob_path(files[0], only_path: true)),'gallery')}
  #{render_method('include?(filename)',
 %Q(files = self.files.select {|f| f.filename == filename }
    return (files.length > 0)),'gallery')}
  #{render_method('filenames',
 %Q(data = []
    files = self.files.each {|file| data << file.filename }
    return data),'gallery')}
end) %>
