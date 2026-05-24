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
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        selectedImages.append(data)
                    }
                }
            }
        }
    }
}
