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

@Component
export struct TEST02 {

  @State persons_info_list: PEOPLE_DATA[] = mock();

  build() {
    NavDestination() {
      RelativeContainer() {
        Column({}) {
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
    .title($r('app.string.entry_test02'))
  }
}
