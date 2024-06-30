ActiveAdmin.register Quote do
  # This line must be added after registering author to active admin
  belongs_to :author, optional: true

  permit_params :author_id, :text, tag_ids: []
  index do
    # Add checkboxes to the left of each row
    selectable_column
    # Add a column that displays the ID of each quote
    id_column
    column :author
    column :text
    column :tags do |quote|
      quote.tags.map(&:name).join(", ")
    end
    actions
  end

  filter :author
  filter :text
  filter :tags

  form do |f|
    f.inputs "Quote" do
      f.input :author
      f.input :text
      f.input :tags, as: :check_boxes
    end
    f.actions
  end

  show do
    attributes_table do
      row :author
      row :text
      row :tags do |quote|
        quote.tags.map(&:name).join(", ")
      end
    end
  end
end
