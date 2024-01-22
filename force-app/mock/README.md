- [Ground Rules](#ground-rules)
- [How to use it](#how-to-use-it)

---

# Ground Rules


The implementation of `HttpMock` called by the Apex runtime to send a fake response when an HTTP callout is made after `Test.setMock` has been called.

# How to use it

## Add HttpMock to your test

- You can specify a mock for a few endpoints at once
- Use proper methods to cover HTTP methods (GET, POST)
- The `mock()` method will execute `Test.setMock`

```java
new HttpMock()
     // different methods
     .get('/v2/person/tim', TIM, 200)
     .post('/v2/person/tim', true, 200)

     // body conditions
     .post('/v2/person/tim#"age":33', true, 200)
     .post('/v2/person/tim#"age":null', false, 200)

     // failures
     .get('/v1/persons', false, 505)
     .get('/v2/persons', new CalloutException())

     .mock();
```

```java
@IsTest
private class MyApi_Test {

    private static final PersonApi API = new PersonApi();
    private static final Person JOE = new Person('joe');
    private static final Person TIM = new Person('tim');

    @IsTest
    private static void multipleHttpMethods() {

        // Setup
        new HttpMock()
                // different methods
                .get('/v2/person/tim', TIM, 200)
                .post('/v2/person/tim', true, 200)

                // body conditions
                .post('/v2/person/tim#"age":33', true, 200)
                .post('/v2/person/tim#"age":null', false, 200)

                // failures
                .get('/v1/persons', false, 505)
                .get('/v2/persons', new CalloutException())

                .mock();


        // Exercise + Verify
        Test.startTest();

        System.assertEquals(true,  API.updatePerson(new Person('tim')) );
        System.assertEquals('tim', API.getPerson('tim').name);

        Test.stopTest();
    }
}
```

---

- [Source Code on Github](https://github.com/rsoesemann/apex-httpmock)
