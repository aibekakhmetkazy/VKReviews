import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void

    let avatarImage: UIImage?
    let username: NSAttributedString
    let ratingImage: UIImage?
    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
            cell.avatarImageView.image = avatarImage
            cell.usernameLabel.attributedText = username
            cell.ratingImageView.image = ratingImage
            cell.reviewTextLabel.attributedText = reviewText
            cell.reviewTextLabel.numberOfLines = maxLines
            cell.createdLabel.attributedText = created
            cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.avatarFrame
        usernameLabel.frame = layout.usernameFrame
        ratingImageView.frame = layout.ratingFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
    }
    
    public let avatarImageView = UIImageView()
    public let usernameLabel = UILabel()
    public let ratingImageView = UIImageView()
    
    private func setupCell() {
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        // Настройка аватара
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        contentView.addSubview(avatarImageView)
        
        // Настройка имени пользователя
        usernameLabel.numberOfLines = 1
        contentView.addSubview(usernameLabel)
        
        // Настройка рейтинга
        contentView.addSubview(ratingImageView)
        
    }
    
    // Обновление данных ячейки
    func configure(with config: ReviewCellConfig) {
        avatarImageView.image = config.avatarImage
        usernameLabel.attributedText = config.username
        ratingImageView.image = config.ratingImage
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    private func setupShowMoreButton() {
        showMoreButton.addTarget(self, action: #selector(didTapShowMore), for: .touchUpInside)
    }

    @objc private func didTapShowMore() {
        config?.onTapShowMore(config?.id ?? UUID())
    }
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {
    
    // MARK: - Размеры
    
    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
    
    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()
    
    // MARK: - Фреймы
    
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    
    private(set) var avatarFrame = CGRect.zero
    private(set) var usernameFrame = CGRect.zero
    private(set) var ratingFrame = CGRect.zero
    
    // MARK: - Отступы
    
    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    
    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0
    
    // MARK: - Расчёт фреймов и высоты ячейки
    
    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right
        
        var maxY = insets.top
        var showShowMoreButton = false
        
        
        avatarFrame = CGRect(
            x: insets.left,
            y: insets.top,
            width: Self.avatarSize.width,
            height: Self.avatarSize.height
        )
        
        usernameFrame = CGRect(
            x: avatarFrame.maxX + avatarToUsernameSpacing,
            y: insets.top,
            width: maxWidth - insets.right - avatarFrame.maxX - avatarToUsernameSpacing,
            height: config.username.boundingRect(width: maxWidth).height
        )
        
        ratingFrame = CGRect(
            x: insets.left,
            y: avatarFrame.maxY + usernameToRatingSpacing,
            width: config.ratingImage?.size.width ?? 0,
            height: config.ratingImage?.size.height ?? 0
        )
            
            if !config.reviewText.isEmpty() {
                // Высота текста с текущим ограничением по количеству строк.
                let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
                // Максимально возможная высота текста, если бы ограничения не было.
                let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
                // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
                showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight
                
                reviewTextLabelFrame = CGRect(
                    origin: CGPoint(x: insets.left, y: maxY),
                    size: config.reviewText.boundingRect(width: width, height: currentTextHeight).size
                )
                maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
            }
            
            if showShowMoreButton {
                showMoreButtonFrame = CGRect(
                    origin: CGPoint(x: insets.left, y: maxY),
                    size: Self.showMoreButtonSize
                )
                maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
            } else {
                showMoreButtonFrame = .zero
            }
            
            createdLabelFrame = CGRect(
                origin: CGPoint(x: insets.left, y: maxY),
                size: config.created.boundingRect(width: width).size
            )
            
            return createdLabelFrame.maxY + insets.bottom
        }
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
