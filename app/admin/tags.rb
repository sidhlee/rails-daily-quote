ActiveAdmin.register Tag do
  permit_params :name

  index do
    selectable_column
    id_column
    column :name
    actions
  end

  filter :name

  form do |f|
    f.inputs 'Tag' do
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
