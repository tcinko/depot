class Product < ActiveRecord::Base

  has_many :line_items
  has_many :orders, through: :line_items

  before_destroy :ensure_not_referenced_by_any_line_item



# -------------------- validates block ---------------------------------------
# ----------------------------------------------------------------------------
  validates_presence_of :title, message: "Поле заголовка должно быть заполнено!"

  validates :description, :image_url, presence: true

  validates :price, numericality: { greater_than_or_equal_to: 0.01,
                      message: "Цена не может быть меньше 0,01." }
  validates :price, numericality: { less_than_or_equal_to: 1_000,
                      message: "Цена не может быть более 1 000 €." }

  validates :title, uniqueness: true, length: { minimum: 10, too_short:
                    "Название должно иметь не менее %{count} символов." }

  validates :image_url, allow_blank: true, format: {
					with: %r{\.(gif|jpg|png)\Z}i,
					message: 'URL must be GIF, JPG or PNG format.' }
# -----------------------------------------------------------------------------


  
#   для кеширования товаров, которые были изменены
  def self.latest
    Product.order(:updated_at).last
  end

  def self.search(search_pattern)
    if search_pattern
      where('title LIKE ?', "%#{search_pattern}%")
    else
      all
    end
  end

#   курсы валют
  RATE_EURO = 0.9
  RATE_UAH  = 22

#   пересчет цены для представлений в зависимости от выбранной локали
  def local_price
    case I18n.locale.to_s
      when 'en' then price
      when 'es' then (price * RATE_EURO).round 2
      when 'ua' then (price * RATE_UAH).round 2
      else price
      end
  end



  private
#   убеждаемся в отсутствии товарных позиций, ссылающихся на данный товар
    def ensure_not_referenced_by_any_line_item
      if line_items.empty?
        return true
      else
        errors.add(:base, 'существуют товарные позиции')
        return false
      end
  end



end

