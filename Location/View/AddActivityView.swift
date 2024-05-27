import SwiftUI
import MapKit
import CoreLocation

struct AddActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: AddActivityViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description)
                }

                Section(header: Text("Image")) {
                    Button(action: {
                        viewModel.isShowingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Select Image")
                        }
                        .foregroundColor(.blue)
                    }

                    if let image = viewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                    }
                }

                Section(header: Text("Additional Information")) {
                    TextField("WhatsApp Link", text: $viewModel.whatsappLinkString)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    DatePicker("Time and Date", selection: $viewModel.time, displayedComponents: [.date, .hourAndMinute])

                    Button(action: {
                        viewModel.isShowingLocationInput = true
                    }) {
                        HStack {
                            Image(systemName: "location")
                            Text("Add Location")
                        }
                        .foregroundColor(.blue)
                    }
                    .sheet(isPresented: $viewModel.isShowingLocationInput) {
                        MapViewWithSearch(coordinate: $viewModel.locationCoordinate, isSheetPresented: $viewModel.isShowingLocationInput)
                            .frame(height: 500)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }

                    if let coordinate = viewModel.locationCoordinate {
                        Text("Location: \(coordinate.latitude), \(coordinate.longitude)")
                    }
                }

                Section {
                    Button(action: {
                        viewModel.saveActivity()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationBarTitle(viewModel.activity != nil ? "Edit Activity" : "New Activity", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $viewModel.isShowingImagePicker) {
                ImagePicker(selectedImage: $viewModel.selectedImage)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
