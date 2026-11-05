import { router } from '@kit.ArkUI';

class PEOPLE_DATA {
  name: string = ""
  age: string = ""
}

function mock(): PEOPLE_DATA[] {
  let persons_info_list: Array<PEOPLE_DATA> = [];
  let person1 : PEOPLE_DATA = { 'name': '马俊豪' ,'age': '21'}
  let person2 : PEOPLE_DATA = { 'name': '张三' ,'age': '5'}
  let person3 : PEOPLE_DATA = { 'name': '李四' ,'age': '50'}
  persons_info_list.push(person1);
  persons_info_list.push(person2);
  persons_info_list.push(person3);
  return persons_info_list;
}

@Entry
@Component
struct TEST02 {

  @State persons_info_list: PEOPLE_DATA[] = mock();
  @State Index: router.RouterOptions = { 'url': 'pages/Index' };


  build() {
    RelativeContainer() {
      Column({}) {
        Button('<', { type: ButtonType.Normal, stateEffect: true })
          .width(50)
          .height(30)
          .fontSize(15)
          .borderRadius(8)
          .backgroundColor(0xF55A42)
          .onClick(()=>{
            this.getUIContext().getRouter().pushUrl(this.Index)
          })
        ForEach(this.persons_info_list, (item: PEOPLE_DATA, index?: number) => {
          Text($r('app.string.person_format', item.name, item.age))
            .fontSize(20)
        }, (item: PEOPLE_DATA, index?: number) => `${index}-${item.name}`)
      }.width('100%').height(300).backgroundColor('rgb(242,242,242)').justifyContent(FlexAlign.SpaceEvenly)
      .constraintSize({ maxWidth: 480 })
    }
    .height('100%')
    .width('100%')
  }
}
