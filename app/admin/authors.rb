ActiveAdmin.register Author do

  permit_params :name

  index do
    selectable_column
    id_column
    column :name
    actions
  end

  filter :name

  form do |f|
    f.inputs 'Author' do
      f.input :name
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
    end
  end
end
