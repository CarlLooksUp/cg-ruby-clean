class Social::CandlesController < Social::SocialController
  helper_method :sort_column, :sort_direction

  CANDLE_FIELDS = [
                    {
                      'key' => 'name_object.name',
                      'label' => 'Fragrance Name',
                      'sortable?' => true
                    },
                    {
                      'key' => 'company',
                      'label' => 'Company',
                      'sortable?' => true
                    },
                    {
                      'key' => 'description',
                      'label' => 'Description',
                      'sortable?' => false
                    },
                    {
                      'key' => 'collection',
                      'label' => 'Product Line',
                      'sortable?' => true
                    }
                   ]

  def index
    @singular = "candle"
    @plural = "candles"
    @nameables = Candle.search_by_name(params[:search])
                       .order(sort_column + " " + sort_direction)
                       .paginate(:page => params[:page], :per_page => 30)
    @columns = CANDLE_FIELDS
    @not_first = request.query_string.present?
  end

  def show
    @singular = "candle"
    @plural = "candles"
    @nameable = Candle.find(params[:id])
    @rows = CANDLE_FIELDS
    render "social/nameable_detail"
  end

  def edit
    
  end

  private
    def sort_column
      permissible = Candle.column_names.clone.concat(NameObject.column_names)
      permissible.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
