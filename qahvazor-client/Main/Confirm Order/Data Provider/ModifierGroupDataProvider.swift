//
//  ModifierGroupDataProvider.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 27/06/26.
//

import Foundation
import UIKit
import Haptica

final class ModifierGroupDataProvider: NSObject {

    // MARK: - Outlets
    weak var collectionView: UICollectionView? {
        didSet {
            collectionView?.dataSource = self
            collectionView?.delegate = self
            collectionView?.allowsSelection = true
            collectionView?.allowsMultipleSelection = false
        }
    }

    // MARK: - Attributes
    weak var viewController: UIViewController?
    weak var collectionViewHeightConstraint: NSLayoutConstraint?

    var groups = [ModifierGroups]() {
        didSet {
            selectedOptionIdsByGroup.removeAll()
            collectionView?.reloadData()
            updateCollectionHeight()
        }
    }

    var hasGroups: Bool {
        return !groups.isEmpty
    }

    var selectedModifiers: [Modification] {
        return groups.enumerated().flatMap { section, group in
            let selectedIds = selectedOptionIdsByGroup[groupIdentifier(group, section: section)] ?? []
            return (group.options ?? []).enumerated().compactMap { row, item in
                selectedIds.contains(optionIdentifier(item, section: section, row: row)) ? item : nil
            }
        }
    }

    private var selectedOptionIdsByGroup = [String: Set<String>]()

    // MARK: - Lifecycle
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }

    func updateCollectionHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self, let collectionView = self.collectionView else { return }
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.setNeedsLayout()
            collectionView.layoutIfNeeded()
            let height = ceil(collectionView.collectionViewLayout.collectionViewContentSize.height)
            guard let heightConstraint = self.collectionViewHeightConstraint else { return }
            guard abs(heightConstraint.constant - height) > 0.5 else { return }

            heightConstraint.constant = height
            self.viewController?.view.layoutIfNeeded()
        }
    }

    func validationMessage() -> String? {
        for (section, group) in groups.enumerated() {
            let selectedCount = selectedOptionIdsByGroup[groupIdentifier(group, section: section)]?.count ?? 0
            let minSelect = group.minSelect ?? 0

            if selectedCount < minSelect {
                return String(format: "modifierMinSelectWarning".localized, minSelect, group.displayTitle)
            }

            if let maxSelect = group.maxSelect, maxSelect > 0, selectedCount > maxSelect {
                return String(format: "modifierMaxSelectWarning".localized, maxSelect, group.displayTitle)
            }
        }

        return nil
    }
}

// MARK: - UICollectionViewDataSource
extension ModifierGroupDataProvider: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return groups.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups[section].options?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ItemsCollectionViewCell.defaultReuseIdentifier,
                for: indexPath
            ) as? ItemsCollectionViewCell,
            let item = groups[indexPath.section].options?[indexPath.row]
        else {
            return UICollectionViewCell()
        }

        cell.configure(with: item, selected: isSelected(indexPath))
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ModifierGroupHeaderView.defaultReuseIdentifier,
            for: indexPath
        )

        if let header = header as? ModifierGroupHeaderView {
            header.configure(with: groups[indexPath.section])
        }

        return header
    }
}

// MARK: - UICollectionViewDelegate
extension ModifierGroupDataProvider: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let option = groups[indexPath.section].options?[indexPath.row] else { return }

        let group = groups[indexPath.section]
        let groupId = groupIdentifier(group, section: indexPath.section)
        let optionId = optionIdentifier(option, section: indexPath.section, row: indexPath.row)
        let minSelect = group.minSelect ?? 0
        let maxSelect = group.maxSelect

        var selectedIds = selectedOptionIdsByGroup[groupId] ?? []

        if selectedIds.contains(optionId) {
            guard selectedIds.count > minSelect else {
                collectionView.reloadItems(at: [indexPath])
                return
            }
            selectedIds.remove(optionId)
        } else if maxSelect == 1 {
            selectedIds = [optionId]
        } else {
            if let maxSelect, maxSelect > 0, selectedIds.count >= maxSelect {
                collectionView.reloadItems(at: [indexPath])
                return
            }
            selectedIds.insert(optionId)
        }

        selectedOptionIdsByGroup[groupId] = selectedIds
        collectionView.reloadSections(IndexSet(integer: indexPath.section))
        updateCollectionHeight()

        if let vc = viewController as? ConfirmOrderViewController {
            vc.updateSelectedModifiers(selectedModifiers)
        }

        Haptic.impact(.light).generate()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ModifierGroupDataProvider: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 34)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 52)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return 10
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }
}

// MARK: - Helpers
private extension ModifierGroupDataProvider {
    func isSelected(_ indexPath: IndexPath) -> Bool {
        guard let option = groups[indexPath.section].options?[indexPath.row] else { return false }
        let groupId = groupIdentifier(groups[indexPath.section], section: indexPath.section)
        let optionId = optionIdentifier(option, section: indexPath.section, row: indexPath.row)
        return selectedOptionIdsByGroup[groupId]?.contains(optionId) == true
    }

    func groupIdentifier(_ group: ModifierGroups, section: Int) -> String {
        return group.key ?? "section-\(section)"
    }

    func optionIdentifier(_ option: Modification, section: Int, row: Int) -> String {
        return option.modificationId ?? "\(section)-\(row)"
    }
}

final class ModifierGroupHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }

    func configure(with group: ModifierGroups) {
        titleLabel.text = group.displayTitle.uppercased()
        let required = (group.minSelect ?? 0) > 0
        statusLabel.text = required ? "modifierRequired".localized : "modifierOptional".localized
        statusLabel.textColor = required ? .appColor(.mainColor) : .secondaryLabel
    }
}

private extension ModifierGroupHeaderView {
    func configureView() {
        backgroundColor = .clear

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = .secondaryLabel

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 11, weight: .bold)
        statusLabel.textAlignment = .right

        addSubview(titleLabel)
        addSubview(statusLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusLabel.leadingAnchor, constant: -12),

            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

private extension ModifierGroups {
    var displayTitle: String {
        return name?.isEmpty == false ? name ?? "" : key ?? ""
    }
}
