import UIKit

// Создание TotalReviewsCell
struct TotalReviewsCellConfig: TableCellConfig {
    static let reuseId = "TotalReviewsCell"
    let count: Int
    
    func update(cell: UITableViewCell) {
        (cell as? TotalReviewsCell)?.configure(count: count)
    }
    
    func height(with size: CGSize) -> CGFloat { 44 }
}

final class TotalReviewsCell: UITableViewCell {
    private let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.textAlignment = .center
        label.font = .reviewCount
        label.textColor = .reviewCount
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(count: Int) {
        label.text = "\(count) отзывов"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
}
