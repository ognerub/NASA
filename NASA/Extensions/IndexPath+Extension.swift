import UIKit

public extension IndexPath {

  func isLastRow(at tableView: UITableView) -> Bool {
    return row == (tableView.numberOfRows(inSection: section) - 1)
  }

  func isLastRow(at collectionView: UICollectionView) -> Bool {
    return row == (collectionView.numberOfItems(inSection: section) - 1)
  }
}
