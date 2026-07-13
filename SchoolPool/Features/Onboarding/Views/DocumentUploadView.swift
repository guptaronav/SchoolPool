import SwiftUI
import PhotosUI

struct DocumentUploadView: View {
    @ObservedObject var vm: OnboardingViewModel

    @State private var studentId = ""
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [Data] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Verify your identity")
                        .font(.largeTitle.bold())
                    Text("Upload your student ID and supporting documents for admin review")
                        .font(.subheadline)
                        .foregroundStyle(Color.spTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                SPTextField(title: "Student ID Number", text: $studentId,
                            keyboard: .default)
                    .padding(.horizontal, 24)

                // Photo picker
                VStack(alignment: .leading, spacing: 12) {
                    Text("Documents (up to 3)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.spTextSecondary)
                        .padding(.horizontal, 24)

                    PhotosPicker(selection: $selectedItems,
                                 maxSelectionCount: 3,
                                 matching: .images) {
                        Label("Choose Photos", systemImage: "photo.on.rectangle.angled")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.spSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.spPrimary.opacity(0.4)))
                    }
                    .padding(.horizontal, 24)

                    // Thumbnail row
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectedImages.indices, id: \.self) { i in
                                    if let uiImg = UIImage(data: selectedImages[i]) {
                                        Image(uiImage: uiImg)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 72, height: 72)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                }

                if let err = vm.errorMessage {
                    Text(err).font(.caption).foregroundStyle(Color.spDanger)
                        .padding(.horizontal, 24)
                }

                SPButton(
                    title: "Submit for Review",
                    isLoading: vm.isLoading
                ) {
                    Task {
                        await vm.submitDocuments(studentIdHash: studentId, documents: selectedImages)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)
        }
        .background(Color.spBackground.ignoresSafeArea())
        .onChange(of: selectedItems) { _, newItems in
            Task {
                selectedImages = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let compressed = Self.compress(data) {
                        selectedImages.append(compressed)
                    }
                }
            }
        }
    }

    /// Downscales + JPEG-compresses so documents fit in a Firestore document
    /// (no Storage bucket needed — documents are stored inline).
    private static func compress(_ data: Data, maxDimension: CGFloat = 1024, quality: CGFloat = 0.5) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: quality)
    }
}
