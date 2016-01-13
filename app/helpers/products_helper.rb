module ProductsHelper

  def product_type_breadcrumb(product_type)
    breadcrumbs = ""
    product_type.path_ids.each do |id|
      unless breadcrumbs.blank?
        breadcrumbs = breadcrumbs + " > " 
      end
      p = ProductType.find id 
      breadcrumbs = breadcrumbs + p.label
    end
    breadcrumbs
  end

end
