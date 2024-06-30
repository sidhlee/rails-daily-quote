ActiveAdmin.register Author do
  permit_params :name, :image_url

  index do
    selectable_column
    id_column
    column :name
    column :image_url
    actions
  end

  filter :name

  form do |f|
    f.inputs "Author" do
      f.input :name
      f.input :image_url
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
    end
  end
end
