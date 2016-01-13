class Social::SkiAreasController < Social::SocialController
  helper_method :sort_column, :sort_direction

  SKI_AREA_FIELDS = [
                      {
                        'key' => 'name_object.name',
                        'label' => 'Ski Area Name',
                        'sortable?' => true
                      },
                      {
                        'key' => 'city',
                        'label' => 'City',
                        'sortable?' => true
                      },
                      {
                        'key' => 'state',
                        'label' => 'State',
                        'sortable?' => true
                      },
                      {
                        'key' => 'country',
                        'label' => 'Country',
                        'sortable?' => true
                      }
                     ]

  def index
    @singular = "ski_area"
    @plural = "ski_areas"
    @nameables = SkiArea.search_by_name(params[:search])
                        .order(sort_column + " " + sort_direction)
                        .paginate(:page => params[:page], :per_page => 30)
    @columns = SKI_AREA_FIELDS 
    @not_first = request.query_string.present?
  end

  def show
    @singular = "ski_area"
    @plural = "ski_areas"
    @nameable = SkiArea.find(params[:id])
    @rows = SKI_AREA_FIELDS
    render "social/nameable_detail"
  end

  def edit
    
  end

  private
    def sort_column
      permissible = SkiArea.column_names.clone.concat(NameObject.column_names)
      permissible.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
