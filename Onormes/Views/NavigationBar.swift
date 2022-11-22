//
//  NavigationBar.swift
//  Onormes
//
//  Created by gonzalo on 09/09/2022.
//

import SwiftUI

/**

This class handles the bar navigation view, redirect the user according to what he has clicked

*/

//  https://truongvankien.medium.com/custom-tabview-in-swiftui-e7c0bf5667ab

struct TabItemData {
    let systemImage: Bool
    let image: String
    //let selectedImage: String
    let title: String
}

struct TabItemView: View {
    let data: TabItemData
    let isSelected: Bool
    
    var body: some View {
        VStack {
            if data.systemImage {
                Image(systemName: data.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(isSelected ? Color(hex: "29245A") : Color(hex: "29245A").opacity(0.51))
                    .frame(width: 28, height: 28)
                    .animation(.default)
            }
            else {
                Image(isSelected ? data.image : data.image + "2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .animation(.default)
            }

            
            Spacer().frame(height: 4)
            
            Text(data.title)
                .foregroundColor(isSelected ? Color(hex: "29245A") : Color(hex: "29245A").opacity(0.51))
                .font(.system(size: 12))
        }
    }
}

struct TabBottomView: View {
    
    let tabbarItems: [TabItemData]
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack {
            Divider()
            
            HStack {
                Spacer()
                ForEach(tabbarItems.indices) { index in
                    let item = tabbarItems[index]
                    Button {
                        self.selectedIndex = index
                    } label: {
                        let isSelected = selectedIndex == index
                        TabItemView(data: item, isSelected: isSelected)
                    }
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)

    }
}

struct TabBottomBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBottomView(tabbarItems: [
            TabItemData(systemImage: true, image: "house.fill", title: "Accueil"),
            TabItemData(systemImage: true, image: "ruler.fill", title: "Mesures"),
            TabItemData(systemImage: false, image: "Scan", title: "Scan"),
            TabItemData(systemImage: false, image: "ProfileImage", title: "Profil"),
        ], selectedIndex: .constant(0))
    }
}

struct CustomTabView<Content: View>: View {
    
    let tabs: [TabItemData]
    @Binding var selectedIndex: Int
    @ViewBuilder let content: (Int) -> Content
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedIndex) {
                ForEach(tabs.indices) { index in
                    content(index)
                        .tag(index)
                }
            }
            
            VStack {
                Spacer()
                TabBottomView(tabbarItems: tabs, selectedIndex: $selectedIndex)
            }
        }
    }
}

struct NavigationBarView: View {
    @State var selectedIndex: Int = 0
      var body: some View {
//        VStack(alignment: .center, content: {
//            TabView {
//                HomeMenu()
//                .tabItem {
//                  Image(systemName: "house")
//                  Text("Accueil")
//                }
//
//                  MeasuresVCRepresented()
//                  .tabItem {
//                      Image(systemName: "ruler.fill")
//                      Text("Mesures").foregroundColor(Color(hex: "29245A"))
//                  }
//
//                  ReconstructionVCRepresented()
//                    .tabItem {
//                      Image("Scan")
//                      Text("Scan")
//                    }
//                  ProfileView()
//                    .tabItem {
//                      Image("ProfileImage").renderingMode(.template)
//                      Text("Profil")
//                    }
//            }.accentColor(Color(hex: "29245A"))
//        }).navigationBarHidden(true)
          CustomTabView(
            tabs: [
                TabItemData(systemImage: true, image: "house.fill", title: "Accueil"),
                TabItemData(systemImage: true, image: "ruler.fill", title: "Mesures"),
                TabItemData(systemImage: false, image: "Scan", title: "Scan"),
                TabItemData(systemImage: false, image: "ProfileImage", title: "Profil"),
            ],
            selectedIndex: $selectedIndex)
          {
              index in
              getTabView(index: index)
          }
      }
        
    @ViewBuilder
          func getTabView(index: Int) -> some View {
              switch index {
                case 0:
                  HomeMenu()
                case 1:
                  MeasuresVCRepresented()
                case 2:
                  ReconstructionVCRepresented()
                default:
                  ProfileView()
              }
          }

}

struct ReconstructionVCRepresented : UIViewControllerRepresentable {
func updateUIViewController(_ uiViewController: ReconstructionViewController, context: Context) {
    
}

func makeUIViewController(context: Context) -> ReconstructionViewController {
  UIStoryboard(name: "Reconstruction", bundle: Bundle.main).instantiateViewController(identifier: "ReconstructionViewController") as! ReconstructionViewController
}
}

struct MeasuresVCRepresented : UIViewControllerRepresentable {
func updateUIViewController(_ uiViewController: AreaViewController, context: Context) {
}

func makeUIViewController(context: Context) -> AreaViewController {
  UIStoryboard(name: "Measure", bundle: Bundle.main).instantiateViewController(identifier: "AreaViewController") as! AreaViewController
}
}
